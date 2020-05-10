<template>
  <n-link :to="`/detail/${name}`">
    <div ref="itemRef" :class="{ 'item--loading': !isIntersected }" class="item">
      <img class="thumnail-img" v-bind:src="imagePath" />
    </div>
  </n-link>
</template>

<style scoped lang="scss">
@keyframes Flash1 {
  0% {
    opacity: 0.5;
  }
  100% {
    opacity: 1;
  }
}
.item {
  width: 100%;
  padding-top: 100%;
  height: auto;
  background: #eeeeee;
  position: relative;

  &--loading {
    animation: Flash1 1s infinite;
  }

  img {
    vertical-align: top;
    position: absolute;
    top: 0;
    left: 0;
  }
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import * as THREE from 'three'
import { run } from '../Canvas/three'
import Canvas from '~/components/Canvas/Canvas.vue'

@Component({
  components: { Canvas }
})
export default class ListItem extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string
  @Prop({ type: String, required: true }) readonly name!: string
  public isIntersected: boolean = false

  get imagePath() {
    const name_ = this.name.replace(/\.glsl/, '')
    return require(`~/assets/thumbnail/${name_}/0001.png`)
  }

  mounted() {
    console.log(this.imagePath)
    const options = {
      root: null,
      rootMargin: '100px 0px 100px 0px',
      threshold: 0.1
    }
    let prev
    const callback: IntersectionObserverCallback = (entries) => {
      if (entries[0].isIntersecting) {
        this.isIntersected = true
      } else {
        this.isIntersected = false
      }
    }
    const observer = new IntersectionObserver(callback, options)
    observer.observe(this.$refs.itemRef as HTMLDivElement)
  }

  create() {
    document.addEventListener('scroll', () => {})
  }
}
</script>
