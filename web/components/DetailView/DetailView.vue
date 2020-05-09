<template>
  <div>
    <h2>{{ name }}</h2>
    <Canvas v-bind="{ shader, name }" />
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
import Canvas from '~/components/Canvas/Canvas.vue'

@Component({ components: { Canvas } })
export default class DetailView extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string
  @Prop({ type: String, required: true }) readonly name!: string
}
</script>
