import { WebSocketServer, WebSocket } from 'ws';
import jwt from 'jsonwebtoken';
import { config } from '../config/index.js';
export class RealtimeGateway {
    clients = new Map(); // userId -> Set of connections
    wss = null;
    heartbeatInterval = null;
    attach(server) {
        this.wss = new WebSocketServer({
            server,
            path: '/v1/realtime',
        });
        this.wss.on('connection', (ws, req) => {
            let authenticatedUserId = null;
            let clientObj = null;
            // Extract optional token from query params or wait for auth frame
            const url = new URL(req.url || '', 'http://localhost');
            const token = url.searchParams.get('token');
            if (token) {
                try {
                    const decoded = jwt.verify(token, config.jwtSecret);
                    authenticatedUserId = decoded.userId;
                    clientObj = { userId: authenticatedUserId, ws, lastPing: Date.now() };
                    this.registerClient(authenticatedUserId, clientObj);
                    ws.send(JSON.stringify({
                        type: 'hello',
                        user_id: authenticatedUserId,
                        server_time: new Date().toISOString(),
                    }));
                }
                catch (err) {
                    // Allow connection to send auth frame
                }
            }
            ws.on('message', (data) => {
                try {
                    const msg = JSON.parse(data.toString());
                    if (msg.type === 'auth') {
                        try {
                            const decoded = jwt.verify(msg.jwt, config.jwtSecret);
                            authenticatedUserId = decoded.userId;
                            if (clientObj) {
                                this.unregisterClient(clientObj.userId, clientObj);
                            }
                            clientObj = { userId: authenticatedUserId, ws, lastPing: Date.now() };
                            this.registerClient(authenticatedUserId, clientObj);
                            ws.send(JSON.stringify({
                                type: 'hello',
                                user_id: authenticatedUserId,
                                server_time: new Date().toISOString(),
                            }));
                        }
                        catch (authErr) {
                            ws.send(JSON.stringify({ type: 'error', code: 4401, message: 'unauthorized' }));
                            ws.close(4401, 'unauthorized');
                        }
                    }
                    else if (msg.type === 'chat.typing') {
                        // Broadcast cosmetic typing to meetup participants
                        if (msg.meetup_id && authenticatedUserId) {
                            this.broadcastToMeetup(msg.meetup_id, {
                                type: 'chat.typing',
                                meetup_id: msg.meetup_id,
                                by: authenticatedUserId,
                            }, [authenticatedUserId]);
                        }
                    }
                    else if (msg.type === 'ping') {
                        if (clientObj)
                            clientObj.lastPing = Date.now();
                        ws.send(JSON.stringify({ type: 'pong', server_time: new Date().toISOString() }));
                    }
                }
                catch (e) {
                    // Ignore malformed frames
                }
            });
            ws.on('close', () => {
                if (clientObj && authenticatedUserId) {
                    this.unregisterClient(authenticatedUserId, clientObj);
                }
            });
        });
        // Heartbeat ticker every 25s
        this.heartbeatInterval = setInterval(() => {
            const now = Date.now();
            for (const [userId, clientSet] of this.clients.entries()) {
                for (const client of clientSet) {
                    if (now - client.lastPing > 60000) {
                        client.ws.terminate();
                        clientSet.delete(client);
                    }
                    else {
                        if (client.ws.readyState === WebSocket.OPEN) {
                            client.ws.ping();
                        }
                    }
                }
                if (clientSet.size === 0) {
                    this.clients.delete(userId);
                }
            }
        }, 25000);
    }
    registerClient(userId, client) {
        if (!this.clients.has(userId)) {
            this.clients.set(userId, new Set());
        }
        this.clients.get(userId).add(client);
    }
    unregisterClient(userId, client) {
        const set = this.clients.get(userId);
        if (set) {
            set.delete(client);
            if (set.size === 0) {
                this.clients.delete(userId);
            }
        }
    }
    sendToUser(userId, event) {
        const clientSet = this.clients.get(userId);
        if (!clientSet)
            return;
        const payload = JSON.stringify(event);
        for (const client of clientSet) {
            if (client.ws.readyState === WebSocket.OPEN) {
                client.ws.send(payload);
            }
        }
    }
    broadcastToMeetup(meetupId, event, excludeUserIds = []) {
        // Exclude specified users if needed
        for (const [userId, clientSet] of this.clients.entries()) {
            if (excludeUserIds.includes(userId))
                continue;
            for (const client of clientSet) {
                if (client.ws.readyState === WebSocket.OPEN) {
                    client.ws.send(JSON.stringify(event));
                }
            }
        }
    }
}
export const realtimeGateway = new RealtimeGateway();
//# sourceMappingURL=gateway.js.map