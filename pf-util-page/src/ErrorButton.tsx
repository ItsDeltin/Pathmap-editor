type ErrorButtonProps = {
    text: string,
    type: string
};

const ErrorButton: React.FC<ErrorButtonProps> = ({ text, type }) => {
    return <div className={"Diagnostic " + type}>
        Error: {text}
    </div>
};

export default ErrorButton;