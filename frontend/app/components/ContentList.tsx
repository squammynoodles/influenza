import { Content } from '@/app/lib/definitions'
import { ContentCard } from './ContentCard'

interface ContentListProps {
  contents: Content[]
  twitterUsername?: string
  emptyMessage?: string
}

export function ContentList({
  contents,
  twitterUsername,
  emptyMessage = 'No content yet',
}: ContentListProps) {
  if (contents.length === 0) {
    return <div className="text-center py-12 text-gray-500">{emptyMessage}</div>
  }

  return (
    <div className="space-y-4">
      {contents.map((content) => (
        <ContentCard
          key={`${content.type}-${content.external_id}`}
          content={content}
          twitterUsername={twitterUsername}
        />
      ))}
    </div>
  )
}
