import * as THREE from 'three'
import { fs, vs } from './shaders'

export const run = (
  container: HTMLDivElement,
  renderer: THREE.WebGLRenderer,
  shader: string,
  hash?: number
) => {
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
    time: { type: 'f', value: hash || Math.random() * 10000 },
    iTime: { type: 'f', value: hash || Math.random() * 10000 },
    resolution: { type: 'v2', value: new THREE.Vector2() },
    iResolution: { type: 'v2', value: new THREE.Vector2() },
    mouse: { type: 'v2', value: new THREE.Vector2() },
    iMouse: { type: 'v2', value: new THREE.Vector2() }
  }

  var material = new THREE.ShaderMaterial({
    uniforms,
    vertexShader: vs,
    fragmentShader: shader
  })

  var mesh = new THREE.Mesh(geometry, material)
  scene.add(mesh)

  // const renderer = new THREE.WebGLRenderer()
  renderer.setPixelRatio(window.devicePixelRatio)

  container.appendChild(renderer.domElement)

  const onWindowResize = () => {
    console.log(container, container.clientWidth, container.clientHeight)
    renderer.setSize(container.clientWidth, container.clientHeight)
    uniforms.resolution.value.x = container.clientWidth
    uniforms.resolution.value.y = container.clientHeight
    uniforms.iResolution.value.x = container.clientWidth
    uniforms.iResolution.value.y = container.clientHeight
  }
  onWindowResize()
  window.addEventListener('resize', onWindowResize, false)

  document.onmousemove = function(e) {
    uniforms.mouse.value.x = e.pageX
    uniforms.iMouse.value.x = e.pageX
    uniforms.mouse.value.y = e.pageY
    uniforms.iMouse.value.y = e.pageY
  }

  function animate() {
    console.log(uniforms)
    // requestAnimationFrame(animate)
    render()
  }
  animate()

  function render() {
    uniforms.time.value += 0.05
    uniforms.iTime.value += 0.05
    renderer.render(scene, camera)
  }

  return { render }
}
