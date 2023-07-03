import React from "react";
import ErrorButton from '../ErrorButton';

export interface AppSection {
    title: string
    content: React.JSX.Element
};

export function useTextConverterSection(
    title: string,
    fromPlaceholder: string,
    toPlaceholder: string,
    converter: (input: string) => string | Error): AppSection {
    const textStyle: React.CSSProperties = {
        resize: 'none',
        width: '40%',
        height: '300px'
    };
    const [inputText, setInputText] = React.useState('');
    const [exportText, setExportText] = React.useState('');
    const [errorText, setErrorText] = React.useState('');

    return {
        title,
        content: <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <textarea style={textStyle} placeholder={fromPlaceholder} value={inputText} onChange={e => setInputText(e.target.value)} />
                <div style={{ fontSize: 50, margin: 10 }}>
                    <button onClick={e => {
                        // Convert
                        const result = converter(inputText);

                        if (result instanceof Error) {
                            setErrorText(result.message);
                        } else {
                            setExportText(result);
                            setErrorText('');
                        }
                    }}>Convert</button>
                    <br />
                    →
                </div>
                <textarea style={textStyle} placeholder={toPlaceholder} value={exportText} onChange={e => setExportText(e.target.value)} />
            </div>
            {errorText ? <ErrorButton text={errorText} /> : undefined}
        </div>
    }
}