import * as THREE from 'three'
import { fs, vs } from './shaders'

export const run = (container: HTMLDivElement, shader: string) => {
  //   let container
  //   let camera, scene, renderer
  //   let uniforms

  //   init()

  // container = document.getElementById('container')

  const camera = new THREE.Camera()
  camera.position.z = 1

  const scene = new THREE.Scene()

  var geometry = new THREE.PlaneBufferGeometry(2, 2)

  const uniforms = {
    u_time: { type: 'f', value: 1.0 },
    u_resolution: { type: 'v2', value: new THREE.Vector2() },
    u_mouse: { type: 'v2', value: new THREE.Vector2() }
  }

  var material = new THREE.ShaderMaterial({
    uniforms,
    vertexShader: vs,
    fragmentShader: shader
  })

  var mesh = new THREE.Mesh(geometry, material)
  scene.add(mesh)

  const renderer = new THREE.WebGLRenderer()
  renderer.setPixelRatio(window.devicePixelRatio)

  container.appendChild(renderer.domElement)

  const onWindowResize = () => {
    renderer.setSize(container.clientWidth, container.clientHeight)
    uniforms.u_resolution.value.x = renderer.domElement.width
    uniforms.u_resolution.value.y = renderer.domElement.height
  }
  onWindowResize()
  window.addEventListener('resize', onWindowResize, false)

  //   document.onmousemove = function(e) {
  //     uniforms.u_mouse.value.x = e.pageX
  //     uniforms.u_mouse.value.y = e.pageY
  //   }

  function animate() {
    requestAnimationFrame(animate)
    render()
  }
  animate()

  function render() {
    uniforms.u_time.value += 0.05
    renderer.render(scene, camera)
  }
}
