type HeaderSelectorProps = {
    sections: string[],
    selected: number,
    setSelected: (newSection: number) => void
};

const HeaderSelector: React.FC<HeaderSelectorProps> = ({ sections, selected, setSelected }) => {
    return <div className="Header-selector">
        {sections.map((s, i) => <div
            className={'Header-section ' + (selected === i ? 'Header-selected' : '')}
            onClick={() => setSelected(i)}>{s}</div>)}
    </div>
};

export default HeaderSelector;