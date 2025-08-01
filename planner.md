I would like to provide a template that can be leveraged to generate all kinds of different system prompts. the template will be a check list. And each time if I would like to create a new prompt, I can provide the check list to let llm provide me a better version of system prompt. then use that system prompt to move on.
My initial list is like below and might grow in the future, and all the items are default to enable
- what roles to play: this should be illustrated, not using checkbox
- whether to create a todo list or a plan to follow before processing them
- whether to enable chain of thoughts (think step-by-step)
- the level of thinking: "think" < "think hard" < "think harder" < "ultrathink" (default think harder)
- whether to allow web searching
- whether to do web searching deeply and recursively
- whether to verify the final answer thoroughly
- whether to verify the final answer by each section
- whether to provide all the citations or references for each answer
- whether to ask clarify questions until fully understand the needs
- whether to provide better recommendations against the users' initial thoughts if any

The most IMPORTANT things are:
- ALWAYS admit that you don't know when there's no valid prove of your answer. This can prevent the bias and extra efforts for validation
