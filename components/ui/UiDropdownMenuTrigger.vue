<template>
  <DropdownMenuTrigger
    v-bind="delegatedProps"
    :class="cn('outline-none', props.class)"
  >
    <slot />
  </DropdownMenuTrigger>
</template>

<script setup lang="ts">
import { type HTMLAttributes, computed } from 'vue'
import {
  DropdownMenuTrigger,
} from 'radix-vue'
import { cn } from '~/lib/utils'

interface Props {
  class?: HTMLAttributes['class'] | string
  asChild?: boolean
  disabled?: boolean
}

const props = defineProps<Props>()

const delegatedProps = computed(() => {
  const { class: _, ...delegated } = props
  return delegated
})
</script>