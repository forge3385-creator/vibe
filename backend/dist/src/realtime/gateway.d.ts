export declare class RealtimeGateway {
    private clients;
    private wss;
    private heartbeatInterval;
    attach(server: any): void;
    private registerClient;
    private unregisterClient;
    sendToUser(userId: string, event: any): void;
    broadcastToMeetup(meetupId: string, event: any, excludeUserIds?: string[]): void;
}
export declare const realtimeGateway: RealtimeGateway;
