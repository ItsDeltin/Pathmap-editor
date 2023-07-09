import React from "react";
import ErrorButton from '../ErrorButton';

export interface AppSection {
    title: string
    content: React.JSX.Element
};

export interface ConvertResult {
    result?: ConvertSection[],
    diagnostics?: Diagnostic[]
}

export interface ConvertSection {
    title?: string,
    text: string
}

export interface Diagnostic {
    message: string,
    type: 'error' | 'warning'
}

export function errorToConvertResult(error: Error | any): ConvertResult {
    if (error instanceof Error) {
        return { diagnostics: [{ message: error.message, type: "error" }] };
    }
    return { diagnostics: [{ message: error, type: "error" }] };
}

export function textToConvertResult(text: string): ConvertResult {
    return { result: [{ text }], diagnostics: [] }
}

export function useTextConverterSection(
    title: string,
    description: React.JSX.Element | undefined,
    buttonText: string,
    fromPlaceholder: string,
    toPlaceholder: string,
    converter: (input: string) => ConvertResult | undefined): AppSection {
    const textStyle: React.CSSProperties = {
        resize: 'none',
        flex: '1'
    };
    // Input box
    const [inputText, setInputText] = React.useState('');
    const [exportResult, setExportResult] = React.useState<ConvertSection[]>([{ text: '' }]);
    const [diagnostics, setDiagnostics] = React.useState<Diagnostic[]>([]);

    const textAreaStyle: React.CSSProperties = {
        display: "flex",
        flex: 1,
        flexDirection: 'column',
        height: '300px'
    };

    return {
        title,
        content: <div>
            {description ? <div className="Section-description">{description}</div> : undefined}
            <div style={{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
                <div style={textAreaStyle}>
                    <textarea style={textStyle} placeholder={fromPlaceholder} value={inputText} onChange={e => setInputText(e.target.value)} />
                </div>
                <div style={{ fontSize: 50, margin: 10 }}>
                    <button onClick={e => {
                        // Convert
                        const result = converter(inputText);

                        if (result?.result) {
                            setExportResult(result.result.length === 0 ? [{text: ''}] : result.result);
                        }
                        if (result?.diagnostics) {
                            setDiagnostics(result.diagnostics);
                        } else {
                            setDiagnostics([]);
                        }
                    }}>{buttonText}</button>
                    <br />
                    →
                </div>
                <div style={textAreaStyle}>{useTextArea(textStyle, toPlaceholder, exportResult, setExportResult)}</div>
            </div>
            {diagnostics.map(d => <ErrorButton text={d.message} type={d.type} />)}
        </div>
    }
}

function useTextArea(textStyle: React.CSSProperties, placeholder: string, exportResult: ConvertSection[], setExportResult: (value: ConvertSection[]) => void) {
    const [selectedResult, setSelectedResult] = React.useState(0);

    const textArea = <textarea style={textStyle} placeholder={placeholder} value={exportResult[selectedResult].text} onChange={e => {
        exportResult[selectedResult].text = e.target.value;
        setExportResult([...exportResult]);
    }} />;

    return exportResult.length === 1 && exportResult[0].title === undefined ?
        textArea : [<select onChange={(e) => {
            setSelectedResult(e.target.selectedIndex);
        }} style={{marginBottom: '10px'}}>
            {exportResult.map((result, i) => <option selected={selectedResult === i}>{result.title}</option>)}
        </select>,
        <br/>,
        textArea];
}