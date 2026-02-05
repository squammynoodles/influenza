'use client'

import { useTransition } from 'react'

interface UnlinkButtonProps {
  action: () => Promise<void>
  type: 'channel' | 'account'
}

export default function UnlinkButton({ action, type }: UnlinkButtonProps) {
  const [isPending, startTransition] = useTransition()

  const handleUnlink = () => {
    if (!confirm(`Are you sure you want to unlink this ${type}?`)) {
      return
    }
    startTransition(async () => {
      await action()
    })
  }

  return (
    <button
      onClick={handleUnlink}
      disabled={isPending}
      className="text-sm text-red-600 hover:text-red-800 disabled:opacity-50"
    >
      {isPending ? 'Unlinking...' : 'Unlink'}
    </button>
  )
}
