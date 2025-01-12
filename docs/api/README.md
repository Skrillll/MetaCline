# API Documentation

## Overview

This document provides comprehensive documentation for all APIs used in MetaCline, including internal extension APIs, external service integrations, and WebView communication interfaces.

## VSCode Extension APIs

### 1. Command Registration API

```typescript
interface CommandAPI {
  registerCommand(id: string, handler: (...args: any[]) => any): Disposable;
  executeCommand<T>(command: string, ...rest: any[]): Thenable<T>;
}
```

Key commands:

- `metacline.startSession`: Initiates a new AI session
- `metacline.endSession`: Terminates current AI session
- `metacline.processRequest`: Handles user requests
- `metacline.generateCode`: Triggers code generation
- `metacline.analyzeCode`: Performs code analysis

### 2. WebView API

```typescript
interface WebViewAPI {
  postMessage(message: any): Thenable<boolean>;
  onDidReceiveMessage(callback: (message: any) => void): Disposable;
}
```

Message types:

- `request`: User input/request
- `response`: AI response
- `status`: Session status updates
- `error`: Error notifications
- `suggestion`: Code suggestions

## AI Integration APIs - OpenRouter API

Base URL: `https://openrouter.ai/api/v1`

```typescript
interface OpenRouterAPI {
  async chat(params: {w
    model: string;
    messages: Message[];
    temperature?: number;
    max_tokens?: number;
  }): Promise<ChatResponse>;
}
```

Supported models:

- `deepseek/deepseek-chat`
- `anthropic/claude-3.5-sonnet:beta`
- `gemini-2.0-flash-thinking-exp-1219`
- `gemini-exp-1206`
- `gemini-2.0-flash-exp`
- `openai/o1`

## Internal APIs

### 1. Safety Framework API

```typescript
interface SafetyAPI {
  validateInput(input: string): Promise<ValidationResult>;
  sanitizeOutput(output: string): Promise<string>;
  checkSecurity(code: string): Promise<SecurityCheck>;
  monitorExecution(process: Process): Promise<void>;
}
```

### 2. Code Analysis API

```typescript
interface CodeAnalysisAPI {
  analyze(code: string): Promise<AnalysisResult>;
  suggest(context: CodeContext): Promise<Suggestion[]>;
  validate(code: string): Promise<ValidationResult>;
}
```

### 3. State Management API

```typescript
interface StateAPI {
  get<T>(key: string): T | undefined;
  set<T>(key: string, value: T): void;
  delete(key: string): void;
  clear(): void;
  subscribe(callback: (state: State) => void): Disposable;
}
```

## External Service Integrations

### 1. Supabase Integration

Base URL: `https://[project-id].supabase.co`

```typescript
interface SupabaseAPI {
  auth: AuthAPI;
  storage: StorageAPI;
  database: DatabaseAPI;
}

interface DatabaseAPI {
  from(table: string): QueryBuilder;
  rpc(fn: string, params?: object): Promise<any>;
}
```

### 2. N8N Integration

Base URL: `http://localhost:5678`

```typescript
interface N8NAPI {
  workflows: WorkflowAPI;
  executions: ExecutionAPI;
  credentials: CredentialAPI;
}
```

## Event System

### 1. Event Emitter

```typescript
interface EventEmitter {
  on(event: string, listener: Function): this;
  emit(event: string, ...args: any[]): boolean;
  off(event: string, listener: Function): this;
}
```

Core events:

- `session.start`
- `session.end`
- `request.process`
- `response.received`
- `error.occurred`

### 2. WebSocket Events

```typescript
interface WebSocketEvents {
  onOpen: () => void;
  onMessage: (data: any) => void;
  onClose: () => void;
  onError: (error: Error) => void;
}
```

## Authentication

### 1. OAuth2 Flow

```typescript
interface OAuth2Flow {
  authorize(scopes: string[]): Promise<AuthorizationResult>;
  refreshToken(token: string): Promise<TokenResponse>;
  revokeToken(token: string): Promise<void>;
}
```

### 2. API Key Authentication

```typescript
interface APIKeyAuth {
  setApiKey(key: string): void;
  clearApiKey(): void;
  getAuthHeaders(): Headers;
}
```

## Error Handling

### 1. Error Types

```typescript
interface APIError {
  code: string;
  message: string;
  details?: object;
  stack?: string;
}
```

Common error codes:

- `AUTH_ERROR`: Authentication failed
- `RATE_LIMIT`: Rate limit exceeded
- `INVALID_INPUT`: Invalid request parameters
- `SERVER_ERROR`: Internal server error

### 2. Error Responses

```typescript
interface ErrorResponse {
  status: number;
  error: APIError;
  timestamp: string;
}
```

## Rate Limiting

```typescript
interface RateLimits {
  requests_per_minute: number;
  tokens_per_minute: number;
  concurrent_requests: number;
}
```

Default limits:

- 60 requests per minute
- 100,000 tokens per minute
- 5 concurrent requests

## WebView Communication Protocol

### 1. Message Format

```typescript
interface WebViewMessage {
  type: string;
  payload: any;
  id: string;
  timestamp: number;
}
```

### 2. Response Format

```typescript
interface WebViewResponse {
  id: string;
  success: boolean;
  data?: any;
  error?: APIError;
}
```

## API Versioning

Current API versions:

- Internal API: v1
- External API: v1
- WebView API: v1

Version format: `vMAJOR.MINOR.PATCH`

## Security Considerations

### 1. Authentication Requirements

All API endpoints require one of:

- Valid API key
- OAuth2 token
- Session token

### 2. Rate Limiting

- Implemented using token bucket algorithm
- Separate limits for different API endpoints
- Automatic retry with exponential backoff

### 3. Data Validation

- Input sanitization on all endpoints
- Schema validation for request/response
- Content-type verification

## Appendix

### A. Status Codes

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 429: Too Many Requests
- 500: Internal Server Error

### B. Request Examples

1. Chat Completion Request:

```json
{
  "model": "deepseek/deepseek-chat",
  "messages": [
    {
      "role": "user",
      "content": "Hello, how can I help you today?"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 1000
}
```

2. Code Analysis Request:

```json
{
  "code": "function example() { ... }",
  "language": "typescript",
  "context": {
    "file": "example.ts",
    "line": 1,
    "column": 1
  }
}
```

### C. Response Examples

1. Chat Completion Response:

```json
{
  "id": "resp_12345",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "I'm here to help you with your coding tasks."
      }
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 11,
    "total_tokens": 21
  }
}
```

2. Code Analysis Response:

```json
{
  "suggestions": [
    {
      "type": "improvement",
      "message": "Consider adding type annotations",
      "line": 1,
      "column": 1
    }
  ],
  "metrics": {
    "complexity": 1,
    "maintainability": 85
  }
}
```
