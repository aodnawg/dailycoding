<template>
  <!-- <div> -->
  <!-- <h2>{{name}}</h2> -->
  <div id="canvasBox" ref="canvasRef" />
  <!-- <code class="code">{{ shader }}</code> -->
  <!-- </div> -->
</template>

<style scoped>
h2 {
  font-size: 1.6rem;
  margin-top: 8px;
  margin-bottom: 16px;
}

#canvasBox {
  width: 100%;
  height: 100%;
}

.code {
  background-color: #eeeeee;
  padding: 12px;
  border-radius: 4px;
  display: block;
  margin-top: 32px;
  color: #292929;
  white-space: pre-line;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import * as THREE from 'three'
import { run } from './three'

const makeHash = () => Math.random() * 1000

const throttle = (fn: Function, delay: number) => {
  let timerId: any
  let lastExecTime = 0
  return () => {
    let elapsedTime = performance.now() - lastExecTime
    const execute = () => {
      fn()
      lastExecTime = performance.now()
    }
    if (!timerId) {
      execute()
    }
    if (timerId) {
      clearTimeout(timerId)
    }
    if (elapsedTime > delay) {
      execute()
    } else {
      timerId = setTimeout(execute, delay)
    }
  }
}

@Component
export default class Canvas extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string
  @Prop({ type: String, required: true }) readonly name!: string
  private hash: number = 0
  private render: Function
  private timerId?: any
  private renderer?: any

  constructor() {
    super()
    this.hash = makeHash()
    this.render = () => console.log('clicked')
  }

  mounted() {
    console.log(this.hash)
    this.renderer = new THREE.WebGLRenderer()

    const { render } = run(
      this.$refs.canvasRef as HTMLDivElement,
      this.renderer,
      this.shader,
      this.hash || 0
    )
    this.render = render

    this.timerId = setInterval(render, 1000)
  }

  destroy() {
    clearInterval(this.timerId)
  }

  //   get source() {
  //     return this.shader;
  //   }
}

// export default Vue.extend({
//   props: {
//     shader: {
//       type: Object,
//       required: true
//     } as PropOptions<Shader>
//   }
// })
//
</script>
