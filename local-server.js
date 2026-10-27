const http = require('http');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');

const root = __dirname;
const port = Number(process.argv[2] || 8000);
const mediaExtensions = new Set(['.png', '.jpg', '.jpeg', '.gif', '.webp', '.avif', '.bmp', '.mp4', '.m4v', '.mov', '.webm', '.ogv', '.ogg']);
const contentTypes = {
    '.css': 'text/css; charset=utf-8',
    '.html': 'text/html; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.mp4': 'video/mp4',
    '.webm': 'video/webm',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ttf': 'font/ttf'
};

function isSameRoot(requestedRoot) {
    return requestedRoot && path.resolve(requestedRoot) === root;
}

http.createServer((request, response) => {
    const url = new URL(request.url, `http://${request.headers.host}`);
    if (url.pathname === '/__media-root-check') {
        if (!isSameRoot(url.searchParams.get('root'))) {
            response.writeHead(409);
            return response.end('This server belongs to a different signage folder');
        }
        response.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        return response.end(root);
    }
    if (url.pathname === '/__media-list') {
        const requestedRoot = url.searchParams.get('root');
        if (requestedRoot && !isSameRoot(requestedRoot)) {
            response.writeHead(409);
            return response.end('This server belongs to a different signage folder');
        }
        const files = fs.readdirSync(root, { withFileTypes: true })
            .filter(entry => entry.isFile() && mediaExtensions.has(path.extname(entry.name).toLowerCase()))
            .map(entry => entry.name)
            .sort((left, right) => left.localeCompare(right));
        response.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
        return response.end(JSON.stringify({ files }));
    }
    const relativePath = decodeURIComponent(url.pathname === '/' ? '/admin.html' : url.pathname).replace(/^[/\\]+/, '');
    const filePath = path.resolve(root, relativePath);
    if (filePath !== root && !filePath.startsWith(`${root}${path.sep}`)) {
        response.writeHead(403);
        return response.end('Forbidden');
    }
    fs.readFile(filePath, (error, data) => {
        if (error) {
            response.writeHead(error.code === 'ENOENT' ? 404 : 500);
            return response.end(error.code === 'ENOENT' ? 'Not found' : 'Unable to read file');
        }
        response.writeHead(200, { 'Content-Type': contentTypes[path.extname(filePath).toLowerCase()] || 'application/octet-stream' });
        response.end(data);
    });
}).listen(port, '127.0.0.1', () => {
    console.log(`Serving signage from ${root} at http://127.0.0.1:${port}/`);
});
