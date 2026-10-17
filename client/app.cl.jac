def:pub ClientApp() -> JsxElement {
    has screen: str = "start";
    has case_id: str = "";
    has loading: bool = False;
    has question_text: str = "";
    has selected_suspect: str = "";
    has selected_clue: str = "";
    has accusation_reason: str = "";

    def new_case(e: MouseEvent) {
        screen = "generating";
        loading = True;
    }

    def update_question(e: ChangeEvent) {
        question_text = e.target.value;
    }

    def update_reason(e: ChangeEvent) {
        accusation_reason = e.target.value;
    }

    return <main className="min-h-svh bg-muted/40 px-4 py-8 text-foreground sm:px-6">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-6">
            <header className="rounded-xl border bg-card p-6 shadow-sm">
                <p className="text-sm font-medium text-primary">Whodunit</p>
                <h1 className="mt-2 text-3xl font-semibold tracking-tight">A mystery is waiting</h1>
                <p className="mt-2 text-sm text-muted-foreground">Question the suspects. Follow the clues. Find the truth.</p>
            </header>
            {if screen == "start" {
                <section className="rounded-xl border bg-card p-8 shadow-sm">
                    <p className="text-muted-foreground">Your case file, suspect interviews, and notebook will appear here.</p>
                    <button className="mt-6 rounded-md bg-primary px-4 py-2 font-medium text-primary-foreground" onClick={new_case}>New Case</button>
                </section>
            } elif screen == "generating" {
                <section className="rounded-xl border bg-card p-8 shadow-sm" aria-live="polite">
                    <h2 className="text-xl font-semibold">Generating your case...</h2>
                    <p className="mt-2 text-muted-foreground">The case file and suspects will appear here.</p>
                </section>
            } elif screen == "play" {
                <section className="grid gap-4 lg:grid-cols-3">
                    <article className="rounded-xl border bg-card p-6 shadow-sm">
                        <h2 className="text-xl font-semibold">Case file</h2>
                        <p className="mt-3 text-muted-foreground">The mystery and four suspects will appear here.</p>
                        <button className="mt-5 rounded-md border px-3 py-2" onClick={new_case}>Accuse</button>
                    </article>
                    <article className="rounded-xl border bg-card p-6 shadow-sm">
                        <h2 className="text-xl font-semibold">Interview</h2>
                        <p className="mt-3 text-muted-foreground">Choose a suspect to question.</p>
                        <label className="mt-4 block text-sm font-medium" htmlFor="question">Your question</label>
                        <input id="question" className="mt-2 w-full rounded-md border bg-background px-3 py-2" value={question_text} onChange={update_question} placeholder="Where were you that evening?" />
                        <button className="mt-3 rounded-md bg-primary px-4 py-2 text-primary-foreground">Ask</button>
                        <button className="ml-2 mt-3 rounded-md border px-4 py-2">Show to suspect</button>
                        <button className="ml-2 mt-3 rounded-md border px-4 py-2">Hint</button>
                    </article>
                    <article className="rounded-xl border bg-card p-6 shadow-sm">
                        <h2 className="text-xl font-semibold">Notebook</h2>
                        <p className="mt-3 text-muted-foreground">Found clues will be collected here.</p>
                        <label className="mt-4 block text-sm font-medium" htmlFor="accusation">Accusation reason</label>
                        <input id="accusation" className="mt-2 w-full rounded-md border bg-background px-3 py-2" value={accusation_reason} onChange={update_reason} placeholder="What connects the suspect to the crime?" />
                    </article>
                </section>
            } else {
                <section className="rounded-xl border bg-card p-8 shadow-sm">
                    <h2 className="text-2xl font-semibold">Case result</h2>
                    <p className="mt-3 text-muted-foreground">The outcome, true story, score, and detective rank will appear here.</p>
                    <button className="mt-6 rounded-md bg-primary px-4 py-2 font-medium text-primary-foreground" onClick={new_case}>Play Again</button>
                </section>
            }}
        </div>
    </main>;
}
