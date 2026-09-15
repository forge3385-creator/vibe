export interface ActivityItem {
    id: string;
    name: string;
}
export interface ActivityGroup {
    type: string;
    label: string;
    subtypes: ActivityItem[];
}
export declare const ACTIVITY_CATALOGUE: ActivityGroup[];
export declare const INTEREST_CATALOGUE: string[];
