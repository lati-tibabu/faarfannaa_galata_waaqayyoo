import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { userService } from '../services/api';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { getUser } from '../lib/session';

const metricConfig = [
  { label: 'Total Users', key: 'totalUsers' },
  { label: 'Admins', key: 'totalAdmins' },
  { label: 'Editors', key: 'totalEditors' },
  { label: 'Regular Users', key: 'totalRegularUsers' },
  { label: 'Devices Seen', key: 'totalDevicesSeen' },
  { label: 'Active Devices (24h)', key: 'activeDevicesLast24Hours' },
  { label: 'Pending Song Changes', key: 'pendingSongChanges' },
];

const AdminDashboard = () => {
  const user = getUser();
  const isAdmin = user?.role === 'admin';
  const [stats, setStats] = useState(null);
  const [recentDevices, setRecentDevices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const response = await userService.getAdminDashboard();
        setStats(response.data.stats);
        setRecentDevices(response.data.recentDevices || []);
      } catch (err) {
        console.error(err);
        setError(err?.response?.data?.error || 'Failed to load admin dashboard.');
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  if (loading) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading dashboard...</div>;
  }

  if (error) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-destructive sm:px-6 lg:px-8">{error}</div>;
  }

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-7 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">{isAdmin ? 'Admin Dashboard' : 'Editor Dashboard'}</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            User management controls and connected-device visibility.
          </p>
        </div>
        <div className="flex gap-2">
          {isAdmin && (
            <Button asChild variant="outline">
              <Link to="/admin/song-changes">Song Reviews</Link>
            </Button>
          )}
          {isAdmin && (
            <Button asChild variant="outline">
              <Link to="/users">Manage Users</Link>
            </Button>
          )}
          <Button asChild>
            <Link to="/songs">Browse Songs</Link>
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {metricConfig.map((metric) => (
          <Card key={metric.key} className="border-border/70 bg-card/90">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">{metric.label}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-semibold tracking-tight">{stats?.[metric.key] ?? 0}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card className="mt-6 border-border/70 bg-card/90">
        <CardHeader>
          <CardTitle className="text-lg">Recent Device Activity</CardTitle>
          <p className="text-sm text-muted-foreground">Last 10 authenticated devices that touched the API.</p>
        </CardHeader>
        <CardContent className="space-y-3">
          {recentDevices.length === 0 ? (
            <p className="text-sm text-muted-foreground">No devices recorded yet.</p>
          ) : (
            recentDevices.map((device) => (
              <div key={device.id} className="rounded-lg border border-border/70 p-3 text-sm">
                <p className="font-medium">
                  {device.user?.name || 'Unknown user'} ({device.user?.role || 'n/a'})
                </p>
                <p className="text-muted-foreground">{device.ipAddress || 'Unknown IP'}</p>
                <p className="line-clamp-1 text-muted-foreground">{device.userAgent || 'Unknown user-agent'}</p>
                <p className="mt-1 text-xs text-muted-foreground">
                  Last seen: {new Date(device.lastSeenAt).toLocaleString()}
                </p>
              </div>
            ))
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default AdminDashboard;
