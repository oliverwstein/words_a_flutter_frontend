import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class ThreeDPointsProjection extends StatefulWidget {
  final Map<String, List<double>> points; // Assuming each value is a List with 3 elements: [x, y, z]

  const ThreeDPointsProjection({Key? key, required this.points}) : super(key: key);

  @override
  State<ThreeDPointsProjection> createState() => _ThreeDPointsProjectionState();
}

class _ThreeDPointsProjectionState extends State<ThreeDPointsProjection> {
  late FlutterGlPlugin three3dRender;
  late three.Scene scene;
  late three.PerspectiveCamera camera;
  late three.WebGLRenderer renderer;
  double dpr = 1.0;
  late double width;
  late double height;
  Size? screenSize;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initPlatformState() async {
    if (screenSize == null) return;

    width = screenSize!.width;
    height = screenSize!.height - 60; // Adjust for app bar or other UI elements

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);
    await three3dRender.prepareContext();

    setState(() {
      initScene();
    });
  }

  void initScene() {
    scene = three.Scene();
    camera = three.PerspectiveCamera(75, width / height, 0.1, 1000);
    camera.position.z = 5;

    renderer = three.WebGLRenderer({"canvas": three3dRender.element, "context": three3dRender.gl});
    renderer.setSize(width, height);

    addPoints();

    animate();
  }

  void addPoints() {
    widget.points.forEach((word, position) {
      var geometry = three.SphereGeometry(0.1, 32, 32);
      var material = three.MeshBasicMaterial({"color": 0xff0000});
      var mesh = three.Mesh(geometry, material);

      mesh.position.x = position[0];
      mesh.position.y = position[1];
      mesh.position.z = position[2];

      scene.add(mesh);
    });
  }

  void animate() {
    if (!mounted) return;

    renderer.render(scene, camera);

    // Schedule the next frame.
    Future.delayed(const Duration(milliseconds: 30), animate);
  }

  @override
  Widget build(BuildContext context) {
    if (screenSize == null) {
      screenSize = MediaQuery.of(context).size;
      dpr = MediaQuery.of(context).devicePixelRatio;
      initPlatformState();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('3D Points Projection')),
      body: three3dRender.isInitialized ? Texture(textureId: three3dRender.textureId!) : Container(),
    );
  }

  @override
  void dispose() {
    three3dRender.dispose();
    super.dispose();
  }
}
