import { EnergyLevel } from '../domain/types.js';
export interface VibeScoreParams {
    energyA: EnergyLevel;
    energyB: EnergyLevel;
    overlapCount: number;
    distanceKm: number;
    radiusKm: number;
    phoneVerified: boolean;
    reportRate: number;
    timeWindowOverlap?: number;
}
export declare function fnComputeVibeScore(params: VibeScoreParams): number;
export declare function calculateHaversineDistance(lat1: number, lon1: number, lat2: number, lon2: number): number;
export declare function jaccardOverlap(setA: string[], setB: string[]): number;
