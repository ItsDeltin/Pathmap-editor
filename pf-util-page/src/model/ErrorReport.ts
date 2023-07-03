interface ErrorReport {
    log(text: string, type: "error" | "warning"): void;
}

export default ErrorReport;
