<template>
  <div>
    <div id="canvasBox" ref="canvasRef" />
    <code class="code">{{ shader }}</code>
  </div>
</template>

<style scoped>
#canvasBox {
  width: 200px;
  height: 200px;
  background: gray;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import * as THREE from 'three'
import { run } from './three'

@Component
export default class Canvas extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string

  mounted() {
    run(this.$refs.canvasRef as HTMLDivElement, this.shader)
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
