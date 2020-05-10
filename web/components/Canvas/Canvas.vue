<template>
  <div class="wrap">
    <div id="canvasBox" ref="canvasRef" />
    <button v-on:click="rerender" class="rerender-button">
      Rerender
      <fa :icon="faSync" />
    </button>
  </div>
</template>

<style scoped>
.wrap {
  margin-bottom: 64px;
}

#canvasBox {
  width: 100%;
  height: 400px;
  margin-bottom: 32px;
}

.rerender-button {
  background-color: transparent;
  border: none;
  cursor: pointer;
  outline: none;
  padding: 0;
  appearance: none;
  background-color: #111111;
  color: #ffffff;
  padding: 8px 16px;
  font-size: 1.4rem;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import * as THREE from 'three'
import { faSync } from '@fortawesome/free-solid-svg-icons'
import { run } from './three'

const makeHash = () => Math.random() * 10000

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
    this.renderer = new THREE.WebGLRenderer()

    const { render } = run(
      this.$refs.canvasRef as HTMLDivElement,
      this.renderer,
      this.shader,
      this.hash || 0
    )
    this.render = () => render(makeHash())
  }

  destroy() {
    clearInterval(this.timerId)
  }

  rerender() {
    this.render()
  }

  get faSync() {
    return faSync
  }
}
</script>
