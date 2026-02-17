import { Navigate, useLocation } from 'react-router-dom';
import { getToken, getUser } from '../lib/session';

const ProtectedRoute = ({ allowedRoles, children }) => {
  const location = useLocation();
  const token = getToken();
  const user = getUser();

  if (!token || !user) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  if (user.role === 'admin' && user.first_login && location.pathname !== '/admin/first-login') {
    return <Navigate to="/admin/first-login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return <Navigate to="/" replace />;
  }

  return children;
};

export default ProtectedRoute;
