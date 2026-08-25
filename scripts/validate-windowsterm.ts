#!/usr/bin/env bun

import { existsSync, readdirSync } from "node:fs";
import { join } from "node:path";

const source = "files/windows/windowsterm-settings.jsonc";
const settingsRelativePath = join(
  "Packages",
  "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
  "LocalState",
  "settings.json",
);

function findLiveSettings() {
  if (process.env.WT_SETTINGS) return process.env.WT_SETTINGS;

  if (process.env.LOCALAPPDATA) {
    const nativePath = join(process.env.LOCALAPPDATA, settingsRelativePath);
    if (existsSync(nativePath)) return nativePath;
  }

  const wslUsers = "/mnt/c/Users";
  if (existsSync(wslUsers)) {
    for (const user of readdirSync(wslUsers)) {
      const wslPath = join(wslUsers, user, "AppData", "Local", settingsRelativePath);
      if (existsSync(wslPath)) return wslPath;
    }
  }
}

const live = findLiveSettings();

async function validate(path: string) {
  const text = await Bun.file(path).text();

  try {
    Bun.JSON5.parse(text);
  } catch (error) {
    throw new Error(`${path}: invalid JSONC\n${error}`);
  }

  console.log(`valid JSONC: ${path}`);
}

await validate(source);

if (live && existsSync(live)) {
  await validate(live);

  console.log("live settings parsed successfully (Windows Terminal may normalize formatting and generate IDs by itself)");
}
