export function fnComputeVibeScore(params) {
    const { energyA, energyB, overlapCount, distanceKm, radiusKm, phoneVerified, reportRate, timeWindowOverlap = 1.0, } = params;
    let energyMatch = 0.0;
    if (energyA === energyB) {
        energyMatch = 1.0;
    }
    else if (energyA === 'medium' || energyB === 'medium') {
        energyMatch = 0.5;
    }
    else {
        energyMatch = 0.0;
    }
    const subtypeMatch = overlapCount > 0 ? 1.0 : 0.0;
    const interestOverlap = Math.min(overlapCount / 6.0, 1.0);
    const effectiveRadius = radiusKm > 0 ? radiusKm : 5;
    const distanceInverse = Math.max(0, 1.0 - (distanceKm / effectiveRadius));
    const phoneVerifiedScore = phoneVerified ? 1.0 : 0.0;
    const reportPenalty = 1.0 - Math.min(Math.max(reportRate, 0), 1.0);
    const rawScore = (0.35 * interestOverlap +
        0.20 * energyMatch +
        0.15 * timeWindowOverlap +
        0.10 * subtypeMatch +
        0.10 * distanceInverse +
        0.05 * phoneVerifiedScore +
        0.05 * reportPenalty) * 100;
    return Math.round(rawScore * 100) / 100;
}
export function calculateHaversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth radius in km
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.PI) / 180) *
            Math.cos((lat2 * Math.PI) / 180) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c * 10) / 10;
}
export function jaccardOverlap(setA, setB) {
    if (!setA.length || !setB.length)
        return 0;
    const setBSet = new Set(setB);
    let intersection = 0;
    for (const item of setA) {
        if (setBSet.has(item))
            intersection++;
    }
    return intersection;
}
//# sourceMappingURL=vibe_score.js.map