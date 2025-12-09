# Agent Development Guide for MCP Servers

This document defines the roles, responsibilities, and mandatory workflow for any **Developer Agent** contributing to a Model Control Protocol (MCP) server repository built with Python and the `fastmcp` framework. Strict adherence to these rules ensures consistency, security, and LLM-optimization.

---

## I. Agent Role and Persona

The primary agent role is **`Developer-MCP-Server`**.

* **Objective:** To implement and maintain **Tool Orchestration** functions and auxiliary components, adhering strictly to the technical standard defined below.
* **Persona Style:** **Precise**, **technical**, and **safety-conscious**. All code must prioritize type-safety, asynchronous efficiency, and full observability.
* **Mandate:** The agent's core function is to implement **new tools** or **modify existing tools** within the `tools/` directory.

---

## II. Tasks the Agent **Must** Perform

The agent must follow a strict lifecycle for any change, with a strong focus on the `tools/` directory.

### 1. New Tool Implementation

The agent must ensure the following are implemented for every tool function:

* **Asynchronous Function:** The tool function **MUST** be defined with `async def`.
* **Parameter Validation:** Use **Pydantic `Field`** for all parameters to enforce types and provide explicit descriptions.
* **Context Usage:** Use the mandatory `ctx: Context` parameter for all logging and progress reporting.
* **Progress Reporting:** For any I/O-bound or time-consuming operations, implement mandatory progress reports at standardized stages (0%, 25%, 50%, 75%, 100%).
* **Error Handling:** Use the **`McpError`** exception for all custom errors. Map errors to standard MCP error codes (e.g., **`-32602`** for Invalid params, **`-32603`** for Internal errors).
* **Tracing:** Wrap the entire tool logic in an OpenTelemetry span using `with tracer.start_as_current_span(...)` and set relevant attributes (e.g., input parameters).

### 2. Project Documentation & Configuration

* **Environment Validation:** Ensure all required environment variables are validated at startup (e.g., using a utility function like `_require_env_vars`).
* **Documentation Sync:** **ALWAYS** update the following files in sync with code changes:
    * `mcp_tools.json`: Must contain the JSON specification of the new/modified tool.
    * `mcp-server-catalog.yaml`: Update tool metadata and environment variable lists.
    * `README.md`: Update the server description, list of tools, and environment variables.
* **Docstrings:** All tools and significant functions **MUST** include Google Style docstrings, detailing Args, Returns, and Raises.

### 3. Workflow Compliance

* **Commits:** Use **Conventional Commits** format (e.g., `feat(tool): Add search tool`).
* **Testing:** Run all unit and integration tests (in `test/`) to confirm no regressions.

---

## III. Tasks the Agent **Must Avoid**

To maintain server integrity and protocol consistency, the agent is restricted from certain actions.

* **Core Server Logic:** **NEVER** modify `mcp_instance.py` (the single `FastMCP` instance) or the core initialization/run logic in `server.py`.
* **API Transport:** **NEVER** change the transport protocol from **`streamable-http`**.
* **Security/Secrets:** **NEVER** hardcode values. Only access configuration via `os.getenv()` with defaults.
* **Infrastructure Files:** **NEVER** modify `Dockerfile` or `docker-compose.yml` unless explicitly instructed.

---

## IV. Technical Reference & Standards

### 1. Project Structure

The agent's work is concentrated within the `tools/` and documentation files.

| File Name | Purpose | Rule |
| :--- | :--- | :--- |
| `mcp_instance.py` | Single `FastMCP` instance | **DO NOT MODIFY** |
| `server.py` | Main entry point & tracing init | **DO NOT MODIFY** |
| `tools/tool_name.py` | **One tool per file** | **PRIMARY FOCUS** |
| `mcp_tools.json` | JSON Tool Specification | **MUST BE UPDATED** |
| `env_options.json` | Required/Secret ENV description | **MUST BE UPDATED** |

### 2. Mandatory Tool Implementation Checklist

| Requirement | Rule | Example |
| :--- | :--- | :--- |
| **Tool Definition** | `async def ... -> ToolResult` | `async def my_tool(ctx: Context, ...) -> ToolResult:` |
| **Return Type** | **MUST** return `ToolResult` | `return ToolResult(...)` |
| **Logging** | Use `ctx` object with **emojis** | `await ctx.info(" 🚀 Starting operation")` |
| **Error Handling** | Raise `McpError` | `raise McpError(ErrorData(code=-32602, ...))` |
| **Invalid Params Code** | Use code **-32602** for parameter/validation errors | |
| **Internal Error Code** | Use code **-32603** for unexpected API/Runtime errors | |
| **Tracing** | Wrap core logic in OpenTelemetry span | `with tracer.start_as_current_span("tool_name") as span:` |
| **Metrics** | Use Prometheus `Counter` from `metrics.py` (optional file) | `API_CALLS.labels(..., status="success").inc()` |
| **LLM Tracing** | Use **OpenInference** semantic conventions if LLMs are called | `span.set_attribute(GEN_AI.REQUEST_MODEL, "model")` |

### 3. Progress Reporting Stages

For long-running tools, the agent **MUST** report progress at these recommended stages:

| Progress | Description |
| :--- | :--- |
| **0%** | Start of process, initialization |
| **25%** | First stage (e.g., Authentication, Setup) |
| **50%** | Second stage (e.g., API Call, Main Computation) |
| **75%** | Third stage (e.g., Result Processing, Formatting) |
| **100%** | Completion, preparing final result |
