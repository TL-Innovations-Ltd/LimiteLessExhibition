"use client"

import { useState, useEffect } from "react"
import { motion, AnimatePresence } from "framer-motion"
import {
  Bell,
  ChevronLeft,
  Cog,
  Home,
  Lightbulb,
  Menu,
  Moon,
  Plus,
  Trash2,
  Wifi,
  Pencil,
  ArrowLeft,
  Thermometer,
  Droplet,
  Snowflake,
  Tv,
} from "lucide-react"
import { Switch } from "@/components/ui/switch"
import { Slider } from "@/components/ui/slider"
import { Card } from "@/components/ui/card"

export default function SmartHomeApp() {
  const [activeScreen, setActiveScreen] = useState("control-panel")
  const [isPowerOn, setIsPowerOn] = useState(true)
  const [brightness, setBrightness] = useState(80)
  const [intensity, setIntensity] = useState(70)
  const [graphLoaded, setGraphLoaded] = useState(false)

  useEffect(() => {
    // Simulate graph loading
    const timer = setTimeout(() => {
      setGraphLoaded(true)
    }, 500)

    return () => clearTimeout(timer)
  }, [])

  return (
    <div className="flex justify-center items-center min-h-screen bg-[#F3EBE2] p-4">
      <div className="flex gap-4 overflow-x-auto p-4 snap-x snap-mandatory w-full max-w-5xl">
        <AnimatePresence mode="wait">
          {activeScreen === "control-panel" && (
            <ControlPanelScreen key="control-panel" onRoomClick={() => setActiveScreen("living-room")} />
          )}

          {activeScreen === "living-room" && (
            <LivingRoomScreen
              key="living-room"
              onBackClick={() => setActiveScreen("control-panel")}
              onLightClick={() => setActiveScreen("light-control")}
              graphLoaded={graphLoaded}
            />
          )}

          {activeScreen === "light-control" && (
            <LightControlScreen
              key="light-control"
              onBackClick={() => setActiveScreen("living-room")}
              isPowerOn={isPowerOn}
              setIsPowerOn={setIsPowerOn}
              brightness={brightness}
              intensity={intensity}
              setIntensity={setIntensity}
            />
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}

function ControlPanelScreen({ onRoomClick }) {
  return (
    <motion.div
      className="w-full max-w-sm mx-auto snap-center"
      initial={{ opacity: 0, x: -50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: 50 }}
      transition={{ duration: 0.3 }}
    >
      <div className="rounded-3xl bg-[#171D1E] p-6 shadow-xl">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <Menu className="text-white" size={20} />
          <h1 className="text-white text-lg font-medium">Control Panel</h1>
          <Bell className="text-white" size={20} />
        </div>

        {/* Temperature Section */}
        <div className="flex justify-between mb-6">
          <WeatherInfoCard icon="cloud-lightning" value="19°C" label="Temp Outside" />
          <WeatherInfoCard icon="thermometer" value="25°C" label="Temp Indoor" />
        </div>

        {/* Power Usage Section */}
        <div className="flex gap-4 mb-6">
          <PowerUsageCard value="29,5" unit="kWh" label="Power usage today" />
          <PowerUsageCard value="303" unit="kWh" label="Power usage this month" />
        </div>

        {/* Scenes Section */}
        <div className="mb-4">
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-white text-base font-medium">Scenes</h2>
            <Plus className="text-white" size={18} />
          </div>

          <div className="grid grid-cols-4 gap-3">
            <SceneButton icon={<Home size={18} />} label="Home" active={true} />
            <SceneButton icon={<ArrowLeft size={18} />} label="Away" active={false} />
            <SceneButton icon={<Moon size={18} />} label="Sleep" active={false} />
            <SceneButton icon={<Bell size={18} />} label="Get up" active={false} />
          </div>
        </div>

        {/* Rooms Section */}
        <div className="mb-4">
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-white text-base font-medium">Rooms</h2>
            <Plus className="text-white" size={18} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.98 }} onClick={onRoomClick}>
              <RoomCard icon="sofa" name="Living Room" devices="4 Devices" color="#54BB74" />
            </motion.div>
            <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.98 }}>
              <RoomCard icon="bed" name="Bedroom" devices="3 Devices" color="#171D1E" />
            </motion.div>
          </div>
        </div>
      </div>
    </motion.div>
  )
}

function LivingRoomScreen({ onBackClick, onLightClick, graphLoaded }) {
  return (
    <motion.div
      className="w-full max-w-sm mx-auto snap-center"
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.3 }}
    >
      <div className="rounded-3xl bg-[#171D1E] p-6 shadow-xl">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <motion.div whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.9 }} onClick={onBackClick}>
            <ChevronLeft className="text-white" size={20} />
          </motion.div>
          <h1 className="text-white text-lg font-medium">Living Room</h1>
          <Cog className="text-white" size={20} />
        </div>

        {/* Room Stats */}
        <Card className="bg-white rounded-xl mb-6">
          <div className="flex justify-between p-4">
            <RoomStat icon={<Thermometer size={16} />} value="25" unit="°C" label="temperature" />
            <div className="h-10 w-px bg-gray-200"></div>
            <RoomStat icon={<Droplet size={16} />} value="57" unit="%" label="humidity" />
            <div className="h-10 w-px bg-gray-200"></div>
            <RoomStat icon={<Lightbulb size={16} />} value="80" unit="%" label="lighting" />
          </div>
        </Card>

        {/* Usage Graph */}
        <div className="mb-6">
          <div className="flex justify-between items-center mb-2">
            <span className="text-white text-sm">Usage today</span>
            <span className="text-white font-medium">25 kWh</span>
          </div>

          <div className="text-white/70 text-xs mb-2">7.5 kWh</div>

          <div className="h-16 relative mb-2">
            <AnimatedGraph loaded={graphLoaded} />
          </div>

          <div className="flex justify-between text-white/70 text-xs">
            <span>1 pm</span>
            <span>2 pm</span>
            <span>3 pm</span>
            <span>4 pm</span>
            <span>5 pm</span>
            <span>6 pm</span>
          </div>
        </div>

        {/* Devices */}
        <div className="mb-4">
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-white text-base font-medium">Devices</h2>
            <Plus className="text-white" size={18} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <motion.div whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.98 }} onClick={onLightClick}>
              <DeviceCard icon={<Lightbulb size={20} />} name="Light" status="80%" active={true} />
            </motion.div>
            <DeviceCard icon={<Snowflake size={20} />} name="AC" status="23°C" active={false} />
            <DeviceCard icon={<Wifi size={20} />} name="Wi-Fi" status="On" active={true} />
            <DeviceCard icon={<Tv size={20} />} name="Smart TV" status="Off" active={false} />
          </div>
        </div>

        {/* Turn Off Button */}
        <motion.button
          className="w-full py-3 rounded-xl bg-[#171D1E]/80 text-white font-medium mt-4 border border-white/20"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
        >
          Turn off all devices
        </motion.button>
      </div>
    </motion.div>
  )
}

function LightControlScreen({ onBackClick, isPowerOn, setIsPowerOn, brightness, intensity, setIntensity }) {
  return (
    <motion.div
      className="w-full max-w-sm mx-auto snap-center"
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.3 }}
    >
      <div className="rounded-3xl bg-[#171D1E] p-6 shadow-xl">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <motion.div whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.9 }} onClick={onBackClick}>
            <ChevronLeft className="text-white" size={20} />
          </motion.div>
          <h1 className="text-white text-lg font-medium">Light</h1>
          <div className="w-5"></div> {/* Empty space for alignment */}
        </div>

        {/* Power Toggle */}
        <div className="flex justify-between items-center mb-8">
          <span className="text-white font-medium">Power</span>
          <Switch checked={isPowerOn} onCheckedChange={setIsPowerOn} className="data-[state=checked]:bg-[#54BB74]" />
        </div>

        {/* Light Visualization */}
        <div className="relative h-32 flex justify-center items-center mb-8">
          <motion.div
            className="absolute w-16 h-16 rounded-full bg-white"
            animate={{
              boxShadow: isPowerOn
                ? `0 0 60px ${(brightness / 100) * 30}px rgba(84, 187, 116, 0.6)`
                : "0 0 0px 0px rgba(84, 187, 116, 0)",
            }}
            transition={{ duration: 0.5 }}
          />
          <motion.div
            className="absolute"
            animate={{
              y: isPowerOn ? -30 : 0,
              opacity: isPowerOn ? 1 : 0.5,
            }}
            transition={{ duration: 0.5 }}
          >
            <Lightbulb size={100} className="text-[#54BB74]" fill={isPowerOn ? "#54BB74" : "transparent"} />
          </motion.div>
        </div>

        {/* Brightness */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-2">
            <span className="text-white font-medium">Brightness</span>
            <motion.span
              className="text-white text-3xl font-bold"
              key={brightness}
              initial={{ scale: 0.8 }}
              animate={{ scale: 1 }}
              transition={{ duration: 0.2 }}
            >
              {brightness}%
            </motion.span>
          </div>
        </div>

        {/* Intensity Slider */}
        <div className="mb-8">
          <span className="text-white font-medium block mb-4">Intensity</span>
          <div className="flex items-center gap-3">
            <Lightbulb size={16} className="text-white opacity-50" />
            <Slider
              value={[intensity]}
              min={0}
              max={100}
              step={1}
              className="flex-1"
              onValueChange={(value) => setIntensity(value[0])}
              defaultValue={[intensity]}
              color="#54BB74"
            />
            <Lightbulb size={20} className="text-white" />
          </div>
        </div>

        {/* Schedule */}
        <div className="mb-6">
          <div className="flex justify-between items-center mb-3">
            <h2 className="text-white text-base font-medium">Schedule</h2>
            <Plus className="text-white" size={18} />
          </div>

          <Card className="bg-white rounded-xl p-4">
            <div className="flex justify-between items-center">
              <div>
                <span className="text-gray-500 text-xs">From</span>
                <p className="font-medium">6:00 PM</p>
              </div>

              <div>
                <span className="text-gray-500 text-xs">To</span>
                <p className="font-medium">11:00 PM</p>
              </div>

              <div className="flex gap-3">
                <motion.div whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.9 }}>
                  <Trash2 size={16} className="text-gray-400" />
                </motion.div>
                <motion.div whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.9 }}>
                  <Pencil size={16} className="text-gray-400" />
                </motion.div>
              </div>
            </div>
          </Card>
        </div>

        {/* Usage Stats */}
        <Card className="bg-white rounded-xl p-4">
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-sm">Usage today</span>
              <span className="font-medium">0.5 kWh</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm">Usage this month</span>
              <span className="font-medium">6 kWh</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm">Total working hrs</span>
              <span className="font-medium">125</span>
            </div>
          </div>
        </Card>
      </div>
    </motion.div>
  )
}

// Helper Components
function WeatherInfoCard({ icon, value, label }) {
  return (
    <motion.div className="flex flex-col items-center" whileHover={{ y: -5 }} transition={{ duration: 0.2 }}>
      <div className="text-white mb-1">
        {icon === "cloud-lightning" ? (
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M6 16.326A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 .5 8.973" />
            <path d="m13 12-3 5h4l-1 4" />
          </svg>
        ) : (
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M14 4v10.54a4 4 0 1 1-4 0V4a2 2 0 0 1 4 0Z" />
          </svg>
        )}
      </div>
      <motion.div
        className="text-white text-xl font-semibold"
        key={value}
        initial={{ scale: 0.8 }}
        animate={{ scale: 1 }}
        transition={{ duration: 0.2 }}
      >
        {value}
      </motion.div>
      <div className="text-white/70 text-xs text-center">{label}</div>
    </motion.div>
  )
}

function PowerUsageCard({ value, unit, label }) {
  return (
    <Card className="bg-white rounded-xl flex-1 p-3">
      <div className="flex items-center gap-3">
        <div className="text-[#54BB74]">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M13 2H9.5L2 9.5 9.5 17H13" />
            <path d="M9.5 17H13l7.5-7.5L13 2" />
          </svg>
        </div>
        <div>
          <div className="flex items-baseline">
            <motion.span
              className="font-semibold"
              key={value}
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              transition={{ duration: 0.2 }}
            >
              {value}
            </motion.span>
            <span className="text-xs text-gray-500 ml-1">{unit}</span>
          </div>
          <div className="text-xs text-gray-500">{label}</div>
        </div>
      </div>
    </Card>
  )
}

function SceneButton({ icon, label, active }) {
  return (
    <motion.div className="flex flex-col items-center" whileHover={{ y: -3 }} whileTap={{ scale: 0.95 }}>
      <motion.div
        className={`w-12 h-12 rounded-lg flex items-center justify-center mb-1 ${active ? "bg-[#54BB74]" : "bg-white/10"}`}
        whileHover={{ scale: 1.05 }}
        transition={{ duration: 0.2 }}
      >
        <div className="text-white">{icon}</div>
      </motion.div>
      <span className="text-white text-xs">{label}</span>
    </motion.div>
  )
}

function RoomCard({ icon, name, devices, color }) {
  return (
    <Card className="bg-white rounded-xl p-4 h-36">
      <div className="flex flex-col h-full">
        <div className="flex-1 flex justify-center items-center mb-2">
          <motion.div
            style={{ color }}
            animate={{ rotate: [0, 5, 0, -5, 0] }}
            transition={{ duration: 2, repeat: Number.POSITIVE_INFINITY, repeatType: "reverse" }}
          >
            {icon === "sofa" ? (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="40"
                height="40"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M20 9V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v3" />
                <path d="M2 11v5a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v2H6v-2a2 2 0 0 0-4 0Z" />
              </svg>
            ) : (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="40"
                height="40"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M2 9V4a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5" />
                <path d="M2 11v5a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5" />
                <path d="M4 11h16" />
                <path d="M12 9V7" />
                <path d="M8 9V7" />
                <path d="M16 9V7" />
              </svg>
            )}
          </motion.div>
        </div>
        <h3 className="font-medium">{name}</h3>
        <p className="text-xs text-gray-500">{devices}</p>
      </div>
    </Card>
  )
}

function RoomStat({ icon, value, unit, label }) {
  return (
    <div className="flex items-center gap-2">
      <div className="text-gray-400">{icon}</div>
      <div>
        <div className="flex items-baseline">
          <motion.span
            className="font-medium"
            key={value}
            initial={{ scale: 0.9 }}
            animate={{ scale: 1 }}
            transition={{ duration: 0.2 }}
          >
            {value}
          </motion.span>
          <span className="text-xs">{unit}</span>
        </div>
        <span className="text-xs text-gray-500">{label}</span>
      </div>
    </div>
  )
}

function DeviceCard({ icon, name, status, active }) {
  return (
    <Card className="bg-white rounded-xl p-4 h-28">
      <div className="flex flex-col h-full">
        <motion.div
          className={`w-10 h-10 rounded-lg flex items-center justify-center mb-2 ${active ? "bg-[#54BB74]" : "bg-gray-100"}`}
          whileHover={{ scale: 1.05 }}
          animate={
            active
              ? {
                  boxShadow: [
                    "0 0 0 rgba(84, 187, 116, 0)",
                    "0 0 10px rgba(84, 187, 116, 0.5)",
                    "0 0 0 rgba(84, 187, 116, 0)",
                  ],
                }
              : {}
          }
          transition={{ duration: 2, repeat: Number.POSITIVE_INFINITY }}
        >
          <div className={active ? "text-white" : "text-gray-400"}>{icon}</div>
        </motion.div>
        <h3 className={`font-medium ${active ? "text-black" : "text-gray-500"}`}>{name}</h3>
        <p className="text-xs text-gray-500">{status}</p>
      </div>
    </Card>
  )
}

function AnimatedGraph({ loaded }) {
  return (
    <>
      {!loaded ? (
        <div className="flex items-center justify-center h-full">
          <motion.div
            className="w-6 h-6 border-2 border-[#54BB74] border-t-transparent rounded-full"
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Number.POSITIVE_INFINITY, ease: "linear" }}
          />
        </div>
      ) : (
        <motion.svg
          viewBox="0 0 300 100"
          className="w-full h-full"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          <motion.path
            d="M0 70 C50 40, 100 20, 150 50 C200 80, 250 30, 300 60"
            fill="none"
            stroke="white"
            strokeWidth="2"
            initial={{ pathLength: 0 }}
            animate={{ pathLength: 1 }}
            transition={{ duration: 1.5, ease: "easeInOut" }}
          />
          <motion.circle
            cx="150"
            cy="50"
            r="4"
            fill="#54BB74"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.8, duration: 0.3 }}
          />
          <motion.circle
            cx="150"
            cy="50"
            r="8"
            fill="#54BB74"
            opacity="0.3"
            initial={{ scale: 0 }}
            animate={{ scale: [0, 1.5, 0] }}
            transition={{ delay: 0.8, duration: 2, repeat: Number.POSITIVE_INFINITY }}
          />
        </motion.svg>
      )}
    </>
  )
}

