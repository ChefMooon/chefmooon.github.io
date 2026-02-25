# HTMLProofer Guide

This document outlines how to use HTMLProofer for link validation on the ChefMoon website and which error types we've decided to ignore.

## What is HTMLProofer?

HTMLProofer is a tool that validates all links (internal and external) in your generated static HTML. It helps catch broken links, missing files, and other link-related issues in your Jekyll site before deployment.

## Installation

HTMLProofer is included in the project's `Gemfile` as a development dependency. Install it with:

```bash
bundle install
```

## Running HTMLProofer

### Standard Command

```bash
bundle exec htmlproofer ./_site --assume-extension --disable-external
```

### Command Explanation

- `htmlproofer` - The main command
- `./_site` - The directory to scan (Jekyll's generated output directory)
- `--assume-extension` - Treats root-relative URLs (e.g., `/about`) as if they have `.html` extension (e.g., `/about.html`)
- `--disable-external` - **Do not check external URLs** (see "Ignored Error Types" below for why)

## Why We Disable External Link Checking

External link checking is disabled (`--disable-external`) for the following reasons:

1. **Network Reliability** - External sites may be temporarily unavailable, have DNS issues, or rate-limit requests, causing false positives
2. **Timeout Issues** - External requests can timeout, especially when many links are checked rapidly
3. **Out of Scope** - The reliability of third-party sites is outside our control and testing their availability adds unnecessary CI/CD failure points
4. **CI/CD Signal** - We want HTMLProofer failures to indicate **our** link problems, not the internet's

### Exceptions

If you need to validate external links (e.g., for a specific audit), you can run:

```bash
bundle exec htmlproofer ./_site --assume-extension
```

**Note:** This will likely fail on transient network issues. Use with caution.

## Ignored Error Types

### ❌ External Links (Disabled)

**Error Example:**
```
External link https://modrinth.com/mod/farmers-delight failed with something very wrong.
It's possible libcurl couldn't connect to the server, or perhaps the request timed out.
```

**Why Ignored:** See section above. External validation adds noise to CI/CD without valuable signal about our own site's health.

## Related Documentation

- [Jekyll Documentation](https://jekyllrb.com/)
- [HTMLProofer GitHub Repository](https://github.com/gjtorikian/html-proofer)
- [Wiki Home System](wiki-home-system.md) - For understanding wiki page structure and paths
