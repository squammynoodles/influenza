import { getUser } from '@/app/lib/dal'
import LogoutButton from '@/app/components/LogoutButton'

export default async function DashboardPage() {
  const user = await getUser()

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Influenza</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-600">{user?.email_address}</span>
            <LogoutButton />
          </div>
        </div>
      </header>
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-medium text-gray-900">Welcome to Influenza</h2>
          <p className="mt-2 text-gray-600">
            Your influencer call tracking dashboard. More features coming soon!
          </p>
          {user?.admin && (
            <div className="mt-4 p-4 bg-indigo-50 rounded-md">
              <p className="text-sm text-indigo-700">
                You are an administrator. Admin features will appear here.
              </p>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
