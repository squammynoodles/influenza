'use client'

import { useRouter, useSearchParams } from 'next/navigation'

interface ContentFiltersProps {
  baseUrl: string
}

export function ContentFilters({ baseUrl }: ContentFiltersProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const currentType = searchParams.get('type') || 'all'

  const handleTypeChange = (type: string) => {
    const params = new URLSearchParams(searchParams)
    if (type === 'all') {
      params.delete('type')
    } else {
      params.set('type', type)
    }
    params.delete('page') // Reset to page 1 on filter change
    const queryString = params.toString()
    router.push(`${baseUrl}${queryString ? `?${queryString}` : ''}`)
  }

  const filters = [
    { value: 'all', label: 'All' },
    { value: 'youtube_video', label: 'Videos' },
    { value: 'tweet', label: 'Tweets' },
  ]

  return (
    <div className="flex gap-2 mb-4">
      {filters.map((filter) => (
        <button
          key={filter.value}
          onClick={() => handleTypeChange(filter.value)}
          className={`px-3 py-1 rounded text-sm ${
            currentType === filter.value
              ? 'bg-gray-900 text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          {filter.label}
        </button>
      ))}
    </div>
  )
}
