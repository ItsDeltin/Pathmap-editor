import { WorkshopValue } from "./workshopValue";

export interface Workshop {
    variables: VariableCollection[] | null;
    actions: Assignment[] | null;
    rules: WorkshopRule[] | null;
}

export interface WorkshopRule {
    name: string;
    eventType: string;
    conditions: WorkshopValue[];
    actions: Assignment[];
}

export interface Assignment {
    isGlobal: boolean;
    identifier: string;
    value: WorkshopValue;
}

export interface VariableCollection {
    isGlobal: boolean;
    variables: DeclaredWorkshopVariable[];
}

export interface DeclaredWorkshopVariable {
    id: number;
    name: string;
}
