import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');
const buildDir = path.join(root, 'flutter_app', 'build', 'web');
const destDir = path.join(root, 'public', 'flutter-dashboard');

async function copyRecursive(src, dest) {
  await fs.mkdir(dest, { recursive: true });
  const entries = await fs.readdir(src, { withFileTypes: true });

  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      await copyRecursive(srcPath, destPath);
    } else {
      await fs.copyFile(srcPath, destPath);
    }
  }
}

try {
  await fs.access(buildDir);
} catch {
  console.error('No se encontró flutter_app/build/web. Ejecuta primero: npm run flutter:build:dashboard');
  process.exit(1);
}

await fs.rm(destDir, { recursive: true, force: true });
await copyRecursive(buildDir, destDir);
console.log(`Flutter Web copiado a public/flutter-dashboard/`);
