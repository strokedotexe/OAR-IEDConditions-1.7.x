/*
 * Open Animation Replacer - IED Condition Extensions
 *
 * Copyright (C) 2023 SlavicPotato
 * Copyright (C) 2026 strokedotexe (Skyrim 1.7.x compatibility rebuild)
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version, with the additional permissions stated in EXCEPTIONS.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>

#include "Conditions.h"
#include "Interface.h"

void InitLogging()
{
	auto path = logs::log_directory();
	if (!path)
		return;

	const auto plugin = SKSE::PluginDeclaration::GetSingleton();
	*path /= fmt::format("{}.log", plugin->GetName());

	std::vector<spdlog::sink_ptr> sinks{
		std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true),
		std::make_shared<spdlog::sinks::msvc_sink_mt>()
	};

#ifndef NDEBUG
	const auto level = spdlog::level::trace;
#else
	const auto level = spdlog::level::info;
#endif

	auto logger = std::make_shared<spdlog::logger>("global", sinks.begin(), sinks.end());
	logger->set_level(level);
	logger->flush_on(level);

	spdlog::set_default_logger(std::move(logger));
	spdlog::set_pattern("[%^%L%$] %v");
}

template <typename T>
void RegisterCondition()
{
	auto result = OAR_API::Conditions::AddCustomCondition<T>();
	switch (result)
	{
	case OAR_API::Conditions::APIResult::OK:
		logs::info("Registered {} condition!", T::CONDITION_NAME);
		break;
	case OAR_API::Conditions::APIResult::AlreadyRegistered:
		logs::warn("Condition {} is already registered!", T::CONDITION_NAME);
		break;
	case OAR_API::Conditions::APIResult::Invalid:
		logs::error("Condition {} is invalid!", T::CONDITION_NAME);
		break;
	case OAR_API::Conditions::APIResult::Failed:
		logs::error("Failed to register condition {}!", T::CONDITION_NAME);
		break;
	}
}

void InitMessaging()
{
	logs::trace("Initializing messaging listener...");
	const auto intfc = SKSE::GetMessagingInterface();
	if (!intfc->RegisterListener([](SKSE::MessagingInterface::Message* a_msg) {
			if (a_msg->type == SKSE::MessagingInterface::kPostPostLoad)
			{
				OAR_API::Conditions::GetAPI(OAR_API::Conditions::InterfaceVersion::V2);
				if (g_oarConditionsInterface)
				{
					RegisterCondition<Conditions::IEDHasEquipmentSlot>();
					RegisterCondition<Conditions::IEDIsBoundWeaponEquipped>();
					RegisterCondition<Conditions::IEDCurrentLocationHasKeyword>();

					if (auto result = PluginInterfaceBase::query_interface<PluginInterfaceIED>())
					{
						g_interfaceIED = result.intfc;
						RegisterCondition<Conditions::IEDNodePlacementCondition>();
						RegisterCondition<Conditions::IEDNodeEquippedPlacementCondition>();
						RegisterCondition<Conditions::IEDNodeParentNameCondition>();
						RegisterCondition<Conditions::IEDPluginOptionCondition>();
					}
					else
					{
						logs::error("Failed to query IED interface: {}"sv, PluginInterfaceIED::get_error_string(result.error));
					}

					if (auto result = PluginInterfaceBase::query_interface<PluginInterfaceSDS>())
					{
						g_interfaceSDS = result.intfc;
						RegisterCondition<Conditions::SDSShieldOnBackEnabledCondition>();
					}
					else
					{
						logs::error("Failed to query SDS interface: {}"sv, PluginInterfaceSDS::get_error_string(result.error));
					}
				}
				else
				{
					logs::error("Failed to request Open Animation Replacer API"sv);
				}
			}
		}))
	{
		stl::report_and_fail("Failed to initialize message listener.");
	}
}

SKSEPluginLoad(const SKSE::LoadInterface* a_skse)
{
	InitLogging();

	const auto plugin = SKSE::PluginDeclaration::GetSingleton();
	logs::info("{} v{} is loading...", plugin->GetName(), plugin->GetVersion());

	SKSE::Init(a_skse);
	InitMessaging();

	logs::info("{} loaded.", plugin->GetName());

	return true;
}
