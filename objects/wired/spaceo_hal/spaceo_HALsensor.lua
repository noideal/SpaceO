function init(virtual)
  if virtual then return end

  self.detectEntityTypes = entity.configParameter("detectEntityTypes")
  self.detectBoundMode = entity.configParameter("detectBoundMode", "CollisionArea")
  local chatCount = 0
  local detectArea = entity.configParameter("detectArea")
  local pos = entity.position()
  if type(detectArea[2]) == "number" then
    --center and radius
    self.detectArea = {
      {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
      detectArea[2]
    }
  elseif type(detectArea[2]) == "table" and #detectArea[2] == 2 then
    --rect corner1 and corner2
    self.detectArea = {
      {pos[1] + detectArea[1][1], pos[2] + detectArea[1][2]},
      {pos[1] + detectArea[2][1], pos[2] + detectArea[2][2]}
    }
  end

  entity.setInteractive(entity.configParameter("interactive", true))
  entity.setAllOutboundNodes(false)
  self.triggerTimer = 0
end

function trigger()
  entity.setAllOutboundNodes(true)
  self.triggerTimer = entity.configParameter("detectDuration")
  local chatOptions = entity.configParameter("chatOptions", {})
  if #chatOptions > 0 and chatCount <=0 then
		entity.say(chatOptions[math.random(1, #chatOptions)])
		chatCount = 1
  end
end

function onInteraction(args)
  trigger()
end

function update(dt) 
  if self.triggerTimer > 0 then
    self.triggerTimer = self.triggerTimer - dt
  elseif self.triggerTimer <= 0 then
    local entityIds = world.entityQuery(self.detectArea[1], self.detectArea[2], {
        withoutEntityId = entity.id(),
        includedTypes = self.detectEntityTypes,
        boundMode = self.detectBoundMode
      })
    if #entityIds > 0 then
      trigger()
    else
	  chatCount = 0
      entity.setAllOutboundNodes(false)
    end
  end
end
