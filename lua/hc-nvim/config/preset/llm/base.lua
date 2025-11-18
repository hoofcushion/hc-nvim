return {
 dependencies={
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
 },
 cmd={
  "LLMSessionToggle",
  "LLMSelectedTextHandler",
  "LLMAppHandler",
 },
 config=function()
  require("llm").setup({
   url="https://localhost:11434/api/generate",
   model="qwen2.5:1.5b",
   api_type="ollama",
  })
 end,
}
