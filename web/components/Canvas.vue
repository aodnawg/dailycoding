<template>
  <div>
    <h2>{{name}}</h2>
    <div id="canvasBox" ref="canvasRef" />
    <code class="code">{{ shader }}</code>
  </div>
</template>

<style scoped>
h2 {
  font-size: 1.6rem;
  margin-top: 8px;
  margin-bottom: 16px;
}

#canvasBox {
  margin: 0 auto;
  width: 100%;
  max-width: 480px;
  height: 60vw;
  max-height: 360px;
  background: gray;
  border-radius: 4px;
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

@Component
export default class Canvas extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string
  @Prop({ type: String, required: true }) readonly name!: string

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
