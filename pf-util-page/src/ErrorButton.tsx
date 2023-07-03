type ErrorButtonProps = {
    text: string
};

const ErrorButton: React.FC<ErrorButtonProps> = ({ text }) => {
    return <div className="Error-button">
        Error: {text}
    </div>
};

export default ErrorButton;