'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "776ac7a56a009a2f3f8ed53c3bda0f9c",
"assets/AssetManifest.bin.json": "0c1591743188fb176fb0f71e4344a3f5",
"assets/assets/Ahaadees/Jami%25E2%2580%2598%2520at-Tirmidhi.jpg": "850d0ed82ac00e85a82cef8d428d5c68",
"assets/assets/Ahaadees/Sahih%2520Al-Bukhari.jpg": "727594f1d62ac68ebb2d25896f7162e6",
"assets/assets/Ahaadees/Sahii%2520Muslam.jpg": "5ef9997055d11b680be75e925c60392d",
"assets/assets/Ahaadees/Sunan%2520Abu%2520Dawood.jpg": "b0f49094a413912d873f72f5b6adcb2d",
"assets/assets/Ahaadees/sunan_ebne_mmajah.jpg": "14b2d6389a3bce7657498045cbc3e17a",
"assets/assets/Ahadeestext/SahiBukhari/topic1.text": "7103cc57f037db99617abe7bf1b02a0e",
"assets/assets/audios/bismillah.mp3": "e5b6ef624c1fb9d37121a0fc0455df2a",
"assets/assets/audios/surah%2520al-fateh.mp3": "06b3d4a20056fc8c2a2176cc786687ee",
"assets/assets/audios/testingaudio.mp3": "f1e3d0d298e7ebdb8791977a967f8db3",
"assets/assets/audios/tickkaudio.wav": "1e2e1c5ea520075db5525da00294a319",
"assets/assets/audios/tiktiktik.mp3": "78ee227092233df419fe19b2d383c6ab",
"assets/assets/Fonts/Amiri-Regular.ttf": "5801fed976868a25cb76c6969c7d46bd",
"assets/assets/Fonts/BebasNeue-Regular.ttf": "b2b293064f557c41411aac04d6f6710d",
"assets/assets/Fonts/NotoNastaliqUrdu-VariableFont_wght.ttf": "f2303a7a5a192a743a836b7d0b62e2fc",
"assets/assets/icons/applogo.png": "be0040a2ac5f7e1a69830e97779dda8d",
"assets/assets/icons/back-button%2520(1).png": "b91c6301d153bcfe6a29f5fa82568078",
"assets/assets/icons/back-button.png": "3f1eb6fa9d7f80ef0797bd8a0d5cbd7a",
"assets/assets/icons/book%2520(1).png": "42888b31492394509fc33c8e65dd1f12",
"assets/assets/icons/book%2520(2).png": "3bba80872f716d17c086f26c1cfc8a58",
"assets/assets/icons/money.png": "c04320f999ac464e342b0021e4108d2f",
"assets/assets/icons/open-book.png": "d9d529b4578eab5ea2a0e7e33685cecb",
"assets/assets/icons/quran%2520(2).png": "56dfb9a0bd6254bd544df5469fd5804c",
"assets/assets/icons/rosary.png": "413706c8a43041dcfc34da553b59f886",
"assets/assets/icons/tasbih.png": "1f03b3d69b61a8d7341737e338181847",
"assets/assets/icons/vibration.png": "9d454d1cb278df99fa2bc9ed62d65b2b",
"assets/assets/icons/volume%2520(1).png": "6cd60f70dcaba2afd233797fa2812fed",
"assets/assets/images/adblockimage.png": "f361bad579e95df9ddd3da1f0247ea2a",
"assets/assets/images/Add%2520a%2520heading.png": "4b0dfec7cfb0bafcb8a9fb79ab68ba2c",
"assets/assets/images/ahadeesbg.png": "a124320233c0074cf63725dfef0ef89a",
"assets/assets/images/ahadeesbgg.png": "79a234449fcd2ed9f44f4faffd163588",
"assets/assets/images/Background.png": "e9d9613ed7a86692b766435fea1f7b5d",
"assets/assets/images/bismillahhh.png": "b2c8d85751bdf30f38de7dc7f300af8f",
"assets/assets/Quran/aaleimran.text": "8b2fff3cb65f00f238fd67a281795ccf",
"assets/assets/Quran/abasa.text": "3d28cd0740ccf8377892a6f1fc31956b",
"assets/assets/Quran/addhuha.text": "ea588e4210bc116ed8ba2df6c981c2ec",
"assets/assets/Quran/addukhan.text": "baed3fdea90c2ab0a9d82a8be6fcf9e6",
"assets/assets/Quran/adhdhariyat.text": "a9f414e48922abc86e3667e6554cb5fc",
"assets/assets/Quran/Al-Hadid": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/Quran/aladiyat.text": "d34f44b493c58e82630caeabc3a9993c",
"assets/assets/Quran/alahqaf.text": "11802eb49b61b02944db1c41107d0169",
"assets/assets/Quran/alahzab.text": "d6deb2ac4904987b10ec1a4aabb529b9",
"assets/assets/Quran/alala.text": "aef55f769374acb5a2636bc8f817c9a6",
"assets/assets/Quran/alalaq.text": "4571a7d8aa2d0a29ef3463d2e2442bf5",
"assets/assets/Quran/alanam.text": "e6efbd83e361d0b17e07fe2dc86d45a8",
"assets/assets/Quran/alanbiya.text": "4d3d1df706f138a7ff592fc95e350155",
"assets/assets/Quran/alanfal.text": "9c872ce68faaca6a0819b95c37d3e85d",
"assets/assets/Quran/alankabut.text": "4313fe4ab9d5a75afaa7e7e88b38e467",
"assets/assets/Quran/alaraf.text": "fbcbbd720f1ab9d1e93db74ce9ad2ba2",
"assets/assets/Quran/alasr.text": "8b4fa2044a08fd0fec81ddfbc0b98f46",
"assets/assets/Quran/albalad.text": "889024f1f042dd504fca51b1c64488e3",
"assets/assets/Quran/albaqarah.text": "27256521ec23be3a6c45838c0f08d3f5",
"assets/assets/Quran/albayyina.text": "a9d8b51f6eafed9c8c56afff63bfd9e1",
"assets/assets/Quran/alburooj.text": "bc458567eee66ec993771ff6e259fc74",
"assets/assets/Quran/alfajr.text": "5497c8e42f135688dffdf7554e217c4d",
"assets/assets/Quran/alfalaq.text": "899d76ef6c7055ef878d2b16ee0ea7d0",
"assets/assets/Quran/alfath.text": "48d9e1295d1274ebf14f10fa25adab20",
"assets/assets/Quran/alfatihah.text": "1084c32e1bb6c5e66217f12e820f41bd",
"assets/assets/Quran/alfil.text": "40b8083a07a65d165ee5c8a4b0da561b",
"assets/assets/Quran/alfurqan.text": "0f3d3166586ea58a82aa6eadeae3a68c",
"assets/assets/Quran/alghashiya.text": "0137bc0f0d091e7766eef4cf732fc84e",
"assets/assets/Quran/alhaaqqa.text": "54b08f46c902e3eb49e6e6d96b10691c",
"assets/assets/Quran/alhadid.text": "b6244cc18fc12db533cd10fa1872f150",
"assets/assets/Quran/alhajj.text": "8d5419f5dc2c191baf64e32c638efd71",
"assets/assets/Quran/alhashr.text": "5548ab2c5b3642ed02cabfce99d12aa3",
"assets/assets/Quran/alhijr.text": "e729d196e85bddc3c6201fb871c22bf8",
"assets/assets/Quran/alhujraat.text": "8cd94d45a44189e3d3485f605a51d1e3",
"assets/assets/Quran/alhumaza.text": "14494acc58d7680f7997930fa51bdb6f",
"assets/assets/Quran/alikhlas.text": "b35a2fbd6f1e1819aa0f7bc5790772e7",
"assets/assets/Quran/alinfitar.text": "b85309b71cb0e79cb71fc6db3c8a2d36",
"assets/assets/Quran/alinsan.text": "cc95dad9296eac75669a183cfe9b0c0f",
"assets/assets/Quran/alinshiqa.text": "16a4f7572ebab5c6b2a7ff135499e52d",
"assets/assets/Quran/alisra.text": "74030ab5826f888ab212ff4ba5d05783",
"assets/assets/Quran/aljathiya.text": "2a31a042bda666fb997e46f9ac1eed52",
"assets/assets/Quran/aljinn.text": "1f2ba65dbf3416fe78ffaf8dbe9fa437",
"assets/assets/Quran/aljumua.text": "d34d17adecaa71aca55bbdbf59b31288",
"assets/assets/Quran/alkafiroon.text": "1c07ff46e5bebeae8cc74a004a8813ab",
"assets/assets/Quran/alkahf.text": "fec0e9c399952d1cb517fc3da27d9b7e",
"assets/assets/Quran/alkawthar.text": "15d09ea6131c6a116e88c4b170a87b6a",
"assets/assets/Quran/allail.text": "976b9388fd027796bce4b029efe8ac4e",
"assets/assets/Quran/almaarij.text": "e1d520a93788b0946f33f94e02529255",
"assets/assets/Quran/almaidah.text": "daa7ec842281a55f7b2332056b50fed1",
"assets/assets/Quran/almasad.text": "318d92b71a5db38d3ec5f6391840e43a",
"assets/assets/Quran/almaun.text": "83abdbb47a5b8ee4e92e803eda44465a",
"assets/assets/Quran/almuddathir.text": "defcaf33aa6d8dfdcee3286dd63f681d",
"assets/assets/Quran/almujadila.text": "f88168531cea38f537d3ac5bb4c6811e",
"assets/assets/Quran/almulk.text": "83631ce0f954310d9545539ef73d2c91",
"assets/assets/Quran/almuminun.text": "fa7fdaadc6037a847cf710165e7df24e",
"assets/assets/Quran/almumtahina.text": "f0a90a3e102d7bc78ebaf252d85fc7d1",
"assets/assets/Quran/almunafiqoon.text": "b84e75bb48cf1fefc22ed7ecfdae2b2e",
"assets/assets/Quran/almursalat.text": "778ac4aec3128026fe1da8b420b6623b",
"assets/assets/Quran/almutaffifin.text": "848eaf6918aabe3c3148655ee0ad5ccb",
"assets/assets/Quran/almuzzammil.text": "838fb8944b55ed669b2c74431a12236e",
"assets/assets/Quran/alqadr.text": "ae383b1494dde0b794968f83522472e0",
"assets/assets/Quran/alqalam.text": "26f3448abd13ac2fe3ab11d4856057c1",
"assets/assets/Quran/alqamar.text": "b2992f4a427abd01ceb8f4700dbd46b9",
"assets/assets/Quran/alqaria.text": "9172ed1c57441118cc268a5061d210c4",
"assets/assets/Quran/alqasas.text": "608d397ea041f04141a5afd700f64042",
"assets/assets/Quran/alqiyama.text": "5086b18ea7458dce35693ae989616de7",
"assets/assets/Quran/alsajda.text": "9b455a467dba1f3452a664cacb493c94",
"assets/assets/Quran/alwaqia.text": "a1d292b8637c3448f6153caf52951e1d",
"assets/assets/Quran/annaba.text": "9767a7b40549266667cffd8f25fe9b3a",
"assets/assets/Quran/annahl.text": "11177006e96cb3feb55369f131f75c9d",
"assets/assets/Quran/annajm.text": "629faaa86a8b75d2f9f4b25c5e945db3",
"assets/assets/Quran/annaml.text": "a5601e57266b5b8cc23eb686d6209126",
"assets/assets/Quran/annas.text": "d4c16a5cb4d635e724ecfda77298ce4b",
"assets/assets/Quran/annasr.text": "45254d03cf74dadec40c0de84bfba4d9",
"assets/assets/Quran/annazi%25E2%2580%2599at.text": "90866632797c809934d2b1250290e3cf",
"assets/assets/Quran/annisa.text": "6fe3e921facb56cf1315434bab6f6e62",
"assets/assets/Quran/annur.text": "68461287a654df0c7951bdc8871003e1",
"assets/assets/Quran/arrad.text": "73ab05347e1a38df5e48f96a5a1a4885",
"assets/assets/Quran/arrahman.text": "d08b4745eb794bf20901c77685b64627",
"assets/assets/Quran/arrum.text": "1539e3c43540467c51acf77b1671e352",
"assets/assets/Quran/ashshams.text": "44e730fd090ab2d2f2d188774235e7de",
"assets/assets/Quran/ashsharh.text": "11e29849739404c78ca927ae2a9fb58b",
"assets/assets/Quran/ashshuara.text": "6e215acd7a43f535cd5c6461eb3b1e6c",
"assets/assets/Quran/ashshura.text": "dd7c1c10b774f38790acbc844f7e68b0",
"assets/assets/Quran/assaff.text": "eb3ba4beade982404f66502ec30f5be2",
"assets/assets/Quran/assaffat.text": "5f6a804a058ac8e68eb7e9c5bfde841c",
"assets/assets/Quran/attaghabun.text": "33a24bff563d3c92fea6058fb823ba21",
"assets/assets/Quran/attahrim.text": "fc0431efe787505bfaa177bd433ecf76",
"assets/assets/Quran/attakathur.text": "228d2062fa5dd63b130692f331d5012c",
"assets/assets/Quran/attakwir.text": "734f73705a6daad2881bd8b7ba3d6f19",
"assets/assets/Quran/attalaq.text": "8ca62c5602415c2c4f32b995abae82d6",
"assets/assets/Quran/attariq.text": "7378ec64e9edc25d363874d6e6ff0c75",
"assets/assets/Quran/attawbah.text": "fc79dc9ed622775f226f944b7e81e31d",
"assets/assets/Quran/attin.text": "2cde74c21d03cdb146fbff989d8e0efc",
"assets/assets/Quran/attur.text": "959302bb1717376ce86ec5e5a28bbf01",
"assets/assets/Quran/azzalzala.text": "d19330a597c1b4d56014152433c8f6fb",
"assets/assets/Quran/azzukhruf.text": "7b3159c67420a91ef093d9cc903c1c54",
"assets/assets/Quran/azzumar.text": "badfae1168d1dda8db7800c0e26af301",
"assets/assets/Quran/fatir.text": "46aef7a03c1255ec576ba7c6eb9ad98b",
"assets/assets/Quran/fussilat.text": "b94dc9c4b71c7d3de9bb9b7bf83e3a57",
"assets/assets/Quran/ghafir.text": "29007a507515f53106d9d5fe390db8d8",
"assets/assets/Quran/hud.text": "6118a63c7d01f001d997bebb580e613d",
"assets/assets/Quran/ibrahim.text": "3765ffc7f8bf1a6e62d3d21653da9ddc",
"assets/assets/Quran/luqman.text": "6d2ff048615eb1e3f3e4523596d8a19e",
"assets/assets/Quran/maryam.text": "57c48f8d2259f3f9eb8751098e5ced72",
"assets/assets/Quran/muhammad.text": "dd48e76b63c0bae2e90cf9585438fd39",
"assets/assets/Quran/nuh.text": "c40cd7c81e7bf216975d0ed16dcb7218",
"assets/assets/Quran/qaf.text": "7b34f7401f4d34d07890512a872e8f29",
"assets/assets/Quran/quraish.text": "d2a7f5e7c008dc8bd959339a91d5c4ab",
"assets/assets/Quran/saba.text": "3e1479f9acd1ff572fa98825352bff7d",
"assets/assets/Quran/sad.text": "c147da09051e3c12d422c926f9660bd9",
"assets/assets/Quran/taha.text": "bdf7e444d5c57110e3c3058711eeab51",
"assets/assets/Quran/yasin.text": "479df0c608068480d0245995fb9bece4",
"assets/assets/Quran/yunus.text": "f39bb254bffe9f8bd9e1c24270d9be81",
"assets/assets/Quran/yusuf.text": "54837aef63c12eceb730b5b4278851a1",
"assets/FontManifest.json": "2f65e6bda6d5448c61a643f993d3c0b7",
"assets/fonts/MaterialIcons-Regular.otf": "b68b34b9727069550b5bc9d606262001",
"assets/NOTICES": "a1ec0a957667c8835d83b0b1479e938e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "d6e048b48b4d6fe46f5e346922048d20",
"assets/packages/flutter_islamic_icons/assets/fonts/IslamicIcons.ttf": "28ee92dd0a0b20a52ec70864df91fcaf",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "9d5dac7d713bb1c5c764c245c403064e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "44aaa0615324a1e8201eed56f29bed62",
"/": "44aaa0615324a1e8201eed56f29bed62",
"main.dart.js": "8d65bc488259dfe315d44844e41b8be7",
"manifest.json": "443fa68479c4c6beb5c5ab281ad63a8f",
"version.json": "138b6c367bb4ddd6e4f6c6bd3122eaf1"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
