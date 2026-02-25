# Release Info Updater

## Overview

The `update_release_info_from_recent_posts.rb` script updates [`_data/minecraft_mod_release_info.yml`](../_data/minecraft_mod_release_info.yml) from changelog post frontmatter.

It scans the most recent posts in `_posts/*/*.md`, reads `mod_id` and `minecraft_version`, and adds any missing Minecraft versions to the matching mod entry in the YAML file.

## What It Checks

- Reads the last 5 posts by default (sorted by `YYYY-MM-DD` from post filenames)
- Parses frontmatter values:
  - `mod_id`
  - `minecraft_version`
- Splits comma-separated versions (for example, `1.21.8, 1.21.10`)
- Ensures each mod has unique version entries in release info data
- Skips duplicates that already exist

## Running the Script

From the repository root:

```bash
ruby scripts/update_release_info_from_recent_posts.rb
```

### Optional Flags

```bash
# Check the latest 10 posts instead of 5
ruby scripts/update_release_info_from_recent_posts.rb --limit 10

# Preview changes without writing the file
ruby scripts/update_release_info_from_recent_posts.rb --dry-run
```

## Output Example

```
frightsdelight: added 1.21.11
Updated .../_data/minecraft_mod_release_info.yml from 5 recent posts.
```

If no updates are needed:

```
No updates needed. Checked 5 recent posts.
```

## Notes

- Mod ID matching is normalized with a canonical lookup key (separator-insensitive), so values like `differentdoors`, `different-doors`, and `different_doors` map reliably.
- If a mod appears in recent posts but does not exist in release info yet, a new mod entry is created.
- Minecraft versions are stored uniquely per mod and written in ascending version order.
