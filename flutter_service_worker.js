'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
"version.json": "f2518bddcdcd63392c9be2e6dfa25450",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/fonts/MaterialIcons-Regular.otf": "d82244dfc9c25791948bbaa4884a56fe",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/AssetManifest.json": "2efbb41d7877d10aac9d091f58ccd7b9",
"assets/AssetManifest.bin": "693635b5258fe5f1cda720cf224f158c",
"assets/AssetManifest.bin.json": "69a99f98c8b1fb8111c5fb961769fcd8",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "ba8feabea3af66564281bca53186bd90",
"icons/android-icon-36x36.png": "c79b443005a41c9970f362fd307e5626",
"icons/android-icon-48x48.png": "e5d5db2b7a0c3a7592ae5c34dbefc3a6",
"icons/android-icon-72x72.png": "bc451e62451fec61a2c141da0a900643",
"icons/android-icon-96x96.png": "4ddc9beecfacc67ea4d04d57364453c9",
"icons/android-icon-144x144.png": "4e7d511292e11e091dd11dbde10760de",
"icons/android-icon-192x192.png": "54b7babb7e6781520f92677f20325ced",
"icons/apple-icon.png": "e0512c9a073321efe9fa9be5a47b9dd4",
"icons/apple-icon-57x57.png": "1f1894b51fb74078b4319305030b3a43",
"icons/apple-icon-60x60.png": "994c16dfd798dbf2bb61545ab1595f05",
"icons/apple-icon-72x72.png": "1b2d5a229db3b6da58fb4345dadaef41",
"icons/apple-icon-76x76.png": "d8518ab2717d57dbebe9e7ba38f0a5b1",
"icons/apple-icon-114x114.png": "bdf0e3f9cceecc2a81adc6b656b63007",
"icons/apple-icon-120x120.png": "6af667cd0c736754f9c91526ad7be317",
"icons/apple-icon-144x144.png": "44b91e8b6367b7f49e3ad38a40e22ee6",
"icons/apple-icon-152x152.png": "1078d9f12f49d98467982ba3ed9a1cb8",
"icons/apple-icon-180x180.png": "6d1cb935fe77575e4c2dafb062b7ad82",
"icons/apple-icon-precomposed.png": "e0512c9a073321efe9fa9be5a47b9dd4",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/favicon.ico": "5f53d6a2c2e5970da65fb462ff5a7bb7",
"icons/favicon-16x16.png": "789f269b7b70aaa281714450ca28b872",
"icons/favicon-32x32.png": "5dcda580b2a990077489e45b3628a3d3",
"icons/favicon-96x96.png": "1957c9830ab7185bba64cb43d1786141",
"icons/manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"icons/ms-icon-70x70.png": "dadd077ceeb344d4b4c98079169577e5",
"icons/ms-icon-144x144.png": "44b91e8b6367b7f49e3ad38a40e22ee6",
"icons/ms-icon-150x150.png": "95a2eddeece7948d326cee09fac78e43",
"icons/ms-icon-310x310.png": "d0d1bf6288f72b8b5657eecace15ba40",
"icons/android-icon-512x512.png": "dfad93075d47da036672faa2aab7a540",
"index.html": "f5bfb928bedb7aeb7e28ea2d8007ebaa",
"/": "f5bfb928bedb7aeb7e28ea2d8007ebaa",
"main.dart.js": "caa60bb4845f66c3245c442935734dfb",
"manifest.json": "a1dce44ab7124cd50dbad588deaea686",
"favicon.png": "a431f97aad254f88a48f07778f41cc17"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
