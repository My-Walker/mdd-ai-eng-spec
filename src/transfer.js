"context7": {
      "type": "local",
      "command": ["context7-mcp.cmd"],
      "environment": {
        "DEFAULT_MINIMUM_TOKENS": "{{DEFAULT_MINIMUM_TOKENS}}"
      }
    },
    "filesystem": {
      "type": "local",
      "command": ["mcp-server-filesystem.cmd", "E:\\work\\project\\git"]
    },
    "tavily": {
      "type": "local",
      "command": ["tavily-mcp.cmd"],
      "environment": {
        "TAVILY_API_KEY": "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"
      }
    },
    "local-agent-tools": {
      "type": "local",
      "command": [
        "node",
        "E:/work/project/git/0-AI-AI前端/demo/MCP-创建/mcp-local-agent-server/dist/index.js"
      ],
      "enabled": true
    }