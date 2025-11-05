// lib/data/quotes.dart
import 'dart:math';

/// 🌿 General motivational quotes — displayed when page opens
final List<String> adhdMotivationalQuotesGeneral = [
  "Focus isn’t about perfection — it’s about showing up again and again.",
  "Small steps forward still count as progress.",
  "Your brain is wired for creativity and curiosity — embrace it.",
  "It’s okay to take longer; you’re still getting there.",
  "Every time you refocus, you strengthen your mind.",
  "You don’t have to do it perfectly — just do it your way.",
  "You are not lazy; your brain just works differently.",
  "Start small — momentum builds with each step.",
  "Be kind to yourself when focus slips — it’s part of learning.",
  "Progress > Perfection. Always.",
  "You are not behind — you’re moving at your own pace.",
  "Your potential is greater than today’s distractions.",
  "Even five minutes of effort is still effort.",
  "You are capable of growth every single day.",
  "You can always restart — there’s no limit to new beginnings.",
  "You’re learning how your brain works — and that’s power.",
  "Focus isn’t easy, but you’re doing it anyway — that’s strength.",
  "Every time you try again, you’re building resilience.",
  "Distractions happen — what matters is returning to your goal.",
  "You’re not broken; you just need systems that work for you.",
  "Even small victories are worth celebrating.",
  "You can’t fail if you keep trying.",
  "The hardest part is starting — and you’ve done that.",
  "Patience with yourself is part of productivity.",
  "You are capable, creative, and resilient — even on off days.",
];

/// 🌟 Success motivational quotes — displayed when user completes their task
final List<String> adhdMotivationalQuotesSuccess = [
  "You did it! Every step you complete strengthens your focus muscles.",
  "Great work! You stayed on track — keep that energy going.",
  "Your persistence paid off — celebrate your win!",
  "You showed your focus who’s boss today. 👏",
  "You proved to yourself that you can do hard things.",
  "That’s how progress looks — one successful session at a time.",
  "You kept your word to yourself — that’s real discipline.",
  "You’re becoming the version of you who follows through. 💪",
  "Every victory, no matter how small, deserves to be noticed.",
  "See what happens when you believe in your focus? 🔥",
  "You turned intention into action — that’s amazing.",
  "Your consistency is quietly building your success story.",
  "You’re not just working — you’re growing stronger each session.",
  "You didn’t just complete a task, you built trust in yourself.",
  "Momentum feels good, doesn’t it? Keep that going!",
  "Another win — and your brain’s thanking you for it.",
  "You stuck with it, even when it wasn’t easy — that’s huge.",
  "Each success builds confidence for the next challenge.",
  "Today you proved effort beats motivation every time.",
  "Celebrate this — you earned it.",
  "You’re training your brain to focus longer each time. 💥",
  "Success isn’t luck — it’s what you just did.",
  "You finished strong — let’s keep this rhythm going.",
  "You showed up, stayed focused, and got it done. That’s victory.",
  "Each win today makes tomorrow’s focus easier.",
];

/// 💛 Failure motivational quotes — displayed when user didn’t complete their task
final List<String> adhdMotivationalQuotesFailure = [
  "You didn’t finish this time — and that’s okay. Trying still counts.",
  "Progress isn’t always about completion — it’s about effort.",
  "You showed up, and that’s what matters most.",
  "Even unfinished work moves you closer to your goal.",
  "Failure isn’t falling short; it’s refusing to try — and you tried!",
  "Today’s effort is tomorrow’s progress.",
  "Every focus attempt strengthens your brain’s attention muscles.",
  "You’re learning what works for you — that’s growth.",
  "Be proud — not perfect. You’re still doing the work.",
  "It’s okay to miss the mark; the fact that you started is powerful.",
  "No focus session is wasted — it’s all training.",
  "The best learners fail forward — you’re doing that beautifully.",
  "Even if you didn’t finish, you made progress others didn’t start.",
  "You’ve already succeeded by refusing to give up.",
  "Your brain is still adapting — give it time.",
  "Every try counts — every effort matters.",
  "You didn’t lose; you learned what to improve next time.",
  "Be gentle with yourself — one step at a time is still movement.",
  "Not finishing doesn’t erase the effort you gave.",
  "You’re still in the game — that’s what’s important.",
  "Rest, reset, and come back stronger. You’ve got this.",
  "This isn’t failure; it’s a pause before your next win.",
  "Focus is a journey — and today was part of it.",
  "You still did something — and that’s worth being proud of.",
  "You’re doing better than you think you are.",
];

/// 🧠 Helper functions
String getRandomGeneralQuote() =>
    adhdMotivationalQuotesGeneral[Random().nextInt(adhdMotivationalQuotesGeneral.length)];

String getRandomSuccessQuote() =>
    adhdMotivationalQuotesSuccess[Random().nextInt(adhdMotivationalQuotesSuccess.length)];

String getRandomFailureQuote() =>
    adhdMotivationalQuotesFailure[Random().nextInt(adhdMotivationalQuotesFailure.length)];
