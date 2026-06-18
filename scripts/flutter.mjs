import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');
const flutterApp = path.join(root, 'flutter_app');

function resolveFlutterBin() {
  if (process.env.FLUTTER_ROOT) {
    return path.join(process.env.FLUTTER_ROOT, 'bin', process.platform === 'win32' ? 'flutter.bat' : 'flutter');
  }

  const candidates = [
    path.join(process.env.USERPROFILE ?? '', 'flutter', 'bin', 'flutter.bat'),
    path.join(process.env.LOCALAPPDATA ?? '', 'flutter', 'bin', 'flutter.bat'),
    'C:\\flutter\\bin\\flutter.bat',
    'C:\\src\\flutter\\bin\\flutter.bat',
  ].filter(Boolean);

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }

  return 'flutter';
}

const flutter = resolveFlutterBin();
const args = process.argv.slice(2);

const result = spawnSync(flutter, args, {
  cwd: flutterApp,
  stdio: 'inherit',
  shell: process.platform === 'win32',
  env: process.env,
});

if (result.error) {
  console.error('\nNo se encontró Flutter en el PATH.');
  console.error('Instálalo en C:\\Users\\<tu-usuario>\\flutter o define FLUTTER_ROOT.');
  console.error('Guía: https://docs.flutter.dev/get-started/install/windows');
  process.exit(1);
}

process.exit(result.status ?? 1);
