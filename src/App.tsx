import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { Layout } from './components/Layout';
import { OrderList } from './components/OrderList';
import { OrderForm } from './components/OrderForm';
import { OrderDetails } from './components/OrderDetails';
import { VehicleList } from './components/Vehicles';
import { VehicleForm } from './components/VehicleForm';
import { EditVehicleForm } from './components/VehicleForm/EditVehicleForm';
import { SettingsPage } from './components/Settings/SettingsPage';
import { DriverList } from './components/DriverList';
import { Login } from './components/Login';
import { SignUp } from './components/SignUp';

function PrivateRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Toaster position="top-right" />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/" element={
            <PrivateRoute>
              <Layout />
            </PrivateRoute>
          }>
            <Route index element={
              <Navigate to="/orders" replace />
            } />
            <Route path="orders" element={<OrderList />} />
            <Route path="orders/new" element={<OrderForm />} />
            <Route path="orders/:id" element={<OrderDetails />} />
            <Route path="vehicles" element={<VehicleList />} />
            <Route path="vehicles/new" element={<VehicleForm />} />
            <Route path="vehicles/:id/edit" element={<EditVehicleForm />} />
            <Route path="drivers" element={<DriverList />} />
            <Route path="settings" element={<SettingsPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}