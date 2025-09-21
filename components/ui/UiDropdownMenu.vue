<template>
  <DropdownMenuRoot>
    <slot name="trigger" />

    <DropdownMenuPortal>
      <DropdownMenuContent
        class="min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
        :side="side"
        :align="align"
        :sideOffset="sideOffset"
      >
        <slot />
      </DropdownMenuContent>
    </DropdownMenuPortal>
  </DropdownMenuRoot>
</template>

<script setup lang="ts">
import {
  DropdownMenuRoot,
  DropdownMenuContent,
  DropdownMenuPortal,
  type DropdownMenuContentProps,
} from 'radix-vue'

interface Props {
  side?: DropdownMenuContentProps['side']
  align?: DropdownMenuContentProps['align']
  sideOffset?: DropdownMenuContentProps['sideOffset']
}

withDefaults(defineProps<Props>(), {
  side: 'bottom',
  align: 'end',
  sideOffset: 4,
})
</script>