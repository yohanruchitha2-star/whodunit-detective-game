"""Start screen + "Generating your case..." state."""

def:pub StartScreen(
    loading: bool,
    loadingMsg: str,
    errorMsg: str,
    onStart: Callable[[], None]
) -> JsxElement {
    def handle_start(_e: MouseEvent) {
        onStart();
    }

    return <div className="flex min-h-svh items-center justify-center px-4 py-10">
        <div className="w-full max-w-xl text-center">
            <span className="inline-block rounded-full border border-primary px-3 py-1 text-xs font-semibold tracking-[0.2em] text-primary">
                AI DETECTIVE
            </span>
            <h1 className="mt-4 text-5xl font-bold tracking-tight">Whodunit</h1>
            <p className="mt-3 text-lg text-muted-foreground">
                A new Sri Lankan mystery every time. Question the suspects, catch a liar, solve the case.
            </p>
            <div className="mt-8 flex min-h-20 flex-col items-center justify-center gap-3" aria-live="polite">
                {if loading {
                    <div className="size-10 animate-spin rounded-full border-4 border-muted border-t-primary"></div>
                    <p className="text-primary">{loadingMsg}</p>
                } else {
                    <button
                        className="rounded-lg bg-primary px-8 py-3 text-lg font-semibold text-primary-foreground hover:bg-primary/85"
                        onClick={handle_start}
                    >
                        New Case
                    </button>
                }}
            </div>
            {errorMsg and <p className="mt-4 text-destructive">{errorMsg}</p>}
            <ol className="mx-auto mt-10 max-w-md list-decimal space-y-1 pl-5 text-left text-muted-foreground">
                <li>Read the case file.</li>
                <li>Question the four suspects. Clues land in your notebook.</li>
                <li>Show a clue to the right suspect to break their lie.</li>
                <li>Accuse the culprit. Fewer questions means a higher score.</li>
            </ol>
        </div>
    </div>;
}
