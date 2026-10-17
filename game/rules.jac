def apply_score(score: int, event: str) -> int {
    change = 0;
    if event == "question" {
        change = -50;
    } elif event == "hint" {
        change = -100;
    } elif event == "crack" {
        change = 150;
    } elif event == "wrong_accuse" {
        change = -300;
    }
    return max(0, score + change);
}

def rank(score: int) -> str {
    if score >= 850 {
        return "Master Detective";
    } elif score >= 600 {
        return "Inspector";
    }
    return "Rookie";
}
