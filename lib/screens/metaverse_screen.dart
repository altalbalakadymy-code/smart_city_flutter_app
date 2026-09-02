import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MetaverseScreen extends StatefulWidget {
  const MetaverseScreen({super.key});

  @override
  State<MetaverseScreen> createState() => _MetaverseScreenState();
}

class _MetaverseScreenState extends State<MetaverseScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  final String _threeJsHtml = '''
<!DOCTYPE html>
<html lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Smart City 3D</title>
  <style>
    body { margin: 0; overflow: hidden; background-color: #0b132b; font-family: sans-serif; }
    #overlay {
      position: absolute; top: 15px; left: 15px;
      color: #00f5d4; font-size: 14px; background: rgba(11,19,43,0.8);
      padding: 10px 14px; border-radius: 8px; border: 1px solid #00f5d4;
    }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
</head>
<body>
  <div id="overlay">🏙️ عالم المدينة الذكية (3D Live)</div>
  <script>
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x0b132b);
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
    scene.add(ambientLight);
    const dirLight = new THREE.DirectionalLight(0x00f5d4, 1.2);
    dirLight.position.set(5, 10, 7);
    scene.add(dirLight);

    const grid = new THREE.GridHelper(50, 50, 0x00f5d4, 0x1c2541);
    scene.add(grid);

    fetch("https://smartcitybackend-production-9d26.up.railway.app/api/v1/admin/businesses")
      .then(res => res.json())
      .then(data => {
        const list = Array.isArray(data) ? data : (data.businesses || []);
        list.forEach((item, index) => {
          const height = 2 + Math.random() * 3;
          const geo = new THREE.BoxGeometry(1.5, height, 1.5);
          const mat = new THREE.MeshStandardMaterial({
            color: index % 2 === 0 ? 0x48cae4 : 0x06d6a0,
            roughness: 0.3,
            metalness: 0.8
          });
          const building = new THREE.Mesh(geo, mat);
          building.position.set((index - list.length / 2) * 3, height / 2, -5);
          scene.add(building);
        });
      })
      .catch(() => {
        const geo = new THREE.BoxGeometry(2, 2, 2);
        const mat = new THREE.MeshStandardMaterial({ color: 0x48cae4 });
        const cube = new THREE.Mesh(geo, mat);
        cube.position.set(0, 1, -5);
        scene.add(cube);
      });

    camera.position.set(0, 3, 5);

    let isDragging = false;
    let prevX = 0;
    window.addEventListener('touchstart', (e) => {
      isDragging = true;
      prevX = e.touches[0].clientX;
    });
    window.addEventListener('touchmove', (e) => {
      if (!isDragging) return;
      const deltaX = e.touches[0].clientX - prevX;
      scene.rotation.y += deltaX * 0.005;
      prevX = e.touches[0].clientX;
    });
    window.addEventListener('touchend', () => { isDragging = false; });

    function animate() {
      requestAnimationFrame(animate);
      renderer.render(scene, camera);
    }
    animate();
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_threeJsHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('الميتافيرس والتوأم الرقمي (3D)'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF00F5D4)),
            ),
        ],
      ),
    );
  }
}
