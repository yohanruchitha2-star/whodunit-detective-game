"""Start screen + "Generating your case..." state."""

def:pub StartScreen(
    loading: bool,
    loadingMsg: str,
    errorMsg: str,
    selected: str,
    onSelect: Callable[[str], None],
    onStart: Callable[[str], None]
) -> JsxElement {
    def handle_start(_e: MouseEvent) {
        onStart(selected);
    }

    def pick_easy(_e: MouseEvent) {
        onSelect("easy");
    }

    def pick_normal(_e: MouseEvent) {
        onSelect("normal");
    }

    def pick_hard(_e: MouseEvent) {
        onSelect("hard");
    }

    easy_tone = "border-primary bg-primary/15" if selected == "easy" else "border-border hover:border-primary/60";
    normal_tone = "border-primary bg-primary/15" if selected == "normal" else "border-border hover:border-primary/60";
    hard_tone = "border-primary bg-primary/15" if selected == "hard" else "border-border hover:border-primary/60";

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
                    <div className="grid w-full grid-cols-3 gap-3 text-left">
                        <button className={"rounded-lg border p-3 " + easy_tone} onClick={pick_easy}>
                            <span className="font-semibold">Easy</span>
                            <span className="mt-1 block text-xs text-muted-foreground">3 suspects, cheap hints, 3 guesses, score x0.8</span>
                        </button>
                        <button className={"rounded-lg border p-3 " + normal_tone} onClick={pick_normal}>
                            <span className="font-semibold">Normal</span>
                            <span className="mt-1 block text-xs text-muted-foreground">4 suspects, 2 guesses, score x1</span>
                        </button>
                        <button className={"rounded-lg border p-3 " + hard_tone} onClick={pick_hard}>
                            <span className="font-semibold">Hard</span>
                            <span className="mt-1 block text-xs text-muted-foreground">5 suspects, evasive, 1 hint, 1 guess, score x1.5</span>
                        </button>
                    </div>
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
                <li>Question the suspects. Clues land in your notebook.</li>
                <li>Show a clue to the right suspect to break their lie.</li>
                <li>Accuse the culprit. Fewer questions means a higher score.</li>
            </ol>
        </div>
    </div>;
}
