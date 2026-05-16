import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

const QuestionSchema = Type.Object({
  question: Type.String(),
  options: Type.Array(Type.String()),
});

const AskParams = Type.Object({
  questions: Type.Array(QuestionSchema),
});

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask",
    label: "Ask",
    description: "Ask the user one or more multiple choice questions",
    promptSnippet: "Get user input via multiple choice questions with custom answer option",
    promptGuidelines: ["Use ask when you need to gather multiple inputs from the user."],
    parameters: AskParams,

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [{ type: "text", text: "UI unavailable" }],
          details: { answers: [] },
        };
      }

      const answers: string[] = [];

      for (const q of params.questions) {
        const choices = [...q.options, "Type custom answer"];
        const answer = await ctx.ui.select(q.question, choices);

        if (!answer) return { content: [{ type: "text", text: "Cancelled" }], details: { answers } };

        if (answer === "Type custom answer") {
          const custom = await ctx.ui.input("Your answer:", "");
          answers.push(custom || "");
        } else {
          answers.push(answer);
        }
      }

      return {
        content: [
          {
            type: "text",
            text: `Answers:\n${answers.map((a, i) => `${i + 1}. ${a}`).join("\n")}`,
          },
        ],
        details: { answers },
      };
    },
  });
}
