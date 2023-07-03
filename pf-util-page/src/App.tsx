import React from 'react';
import './App.css';
import { AppSection, useTextConverterSection } from './model/AppSection';
import HeaderAndContent from './HeaderAndContent';
import { parseActionSet } from './workshop/parseActionSet';
import loadFromWorkshop from './save/LoadFromWorkshop';
import loadFromOldJson from './save/LoadFromOldJson';
import { saveToWorkshop } from './save/PathmapSave';

export const currentVersion: number = 3;

function App() {
    const SECTIONS: AppSection[] = [
        useTextConverterSection(
            'Clean up and update save',
            'Workshop code (Pathmap save)',
            'Workshop code (Cleaned)',
            code => {
                // convert code to workshop.
                const workshop = parseActionSet(code);
                // Parsing error
                if (workshop instanceof Error) {
                    return workshop;
                }
                // Incorrect type
                if (!workshop.actions) {
                    return Error('Save should be a list of actions');
                }
                // Load save
                const pathmap = loadFromWorkshop(workshop.actions, {log(text, type) {
                }
                });
                return '';
            }
        ),
        useTextConverterSection(
            'Pathmap save from compiled workshop code',
            'Workshop code (Compiled pf code)',
            'Workshop code (Pathmap save)',
            code => {
                const { WorkshopDeserialize } = require('@workshopcodes/deserializer');
                const workshopData = WorkshopDeserialize(code);

                // convert code to workshop.
                const workshop = parseActionSet(code);

                if (workshop instanceof Error) {
                    return workshop;
                }
                return 'success!';
            }),
        useTextConverterSection(
            'Convert old OSTW pathmaps',
            'Pathmap json',
            'Workshop code (Pathmap save)',
            code => {
                const map = loadFromOldJson(code);
                if (map instanceof Error) {
                    return map;
                }
                return saveToWorkshop(map);
            })
    ];

    return (
        <div className="App">
            <header className="App-header">Pathmap editor save tool</header>
            <HeaderAndContent sections={SECTIONS} />
        </div>
    );
}

export default App;
