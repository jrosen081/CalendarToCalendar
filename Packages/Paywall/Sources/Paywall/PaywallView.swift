import SwiftUI
import DesignSystem

public struct PaywallPlan: Identifiable {
    public let id: String
    let type: String
    let price: String
    
    public init(id: String, type: String, price: String) {
        self.id = id
        self.type = type
        self.price = price
    }
}

public struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    let reasons: [String]
    let plans: [PaywallPlan]
    @State private var selectedPlan = 0
    
    let onUpgrade: (PaywallPlan) -> Void
    
    public init(reasons: [String], plans: [PaywallPlan], onUpgrade: @escaping (PaywallPlan) -> Void) {
        self.reasons = reasons
        self.plans = plans
        self.onUpgrade = onUpgrade
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 108.0 / 255, green: 56.0 / 255, blue: 1.0, opacity: 0.38),
                Color(red: 108.0 / 255, green: 41.0 / 255, blue: 249.0 / 255, opacity: 0.81)
            ],
                           startPoint: .top,
                           endPoint: .bottom)
            .ignoresSafeArea()
            VStack {
                Text("Calendar to Calendar PRO")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 8)
                Spacer()
                VStack(spacing: 24) {
                    ForEach(reasons, id: \.self) { text in
                        checkMarkView(text: text)
                    }
                }
                Spacer()
                VStack(spacing: 12) {
                    ForEach(plans) { plan in
                        selectionView(plan: plan)
                    }
                }
                
                .padding(.bottom, 40)
                VStack(spacing: 8) {
                    Button {
                        onUpgrade(plans[selectedPlan])
                        dismiss()
                    } label: {
                        Text("UPGRADE")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                Capsule()
                                    .foregroundColor(.blue)
                            }
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("Not Now")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .buttonStyle(.plain)
        }.multilineTextAlignment(.center)
    }
    
   
    private func checkMarkView(text: String) -> some View {
        HStack(spacing: 18) {
            Image(systemName: "checkmark")
                .renderingMode(.template)
                .font(.system(size: 30))
                .foregroundColor(Color(red: 52.0 / 255,
                                       green: 0,
                                       blue: 92.0 / 255))
            Text(text)
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    private func selectionView(plan: PaywallPlan) -> some View {
        let planIndex = plans.firstIndex(where: { $0.id == plan.id })!
        let isSelected = planIndex == selectedPlan
        Text("\(plan.type)\n\(plan.price)")
            .font(isSelected ? .title2.bold() : .title3)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(red: 81.0 / 255,
                                           green: 128.0 / 255,
                                           blue: 131.0 / 255))
                    .border(isSelected ? .black : .clear, width: 4)
                    .cornerRadius(5)
            }
            .opacity(isSelected ? 1 : 0.5)
            .playfulTapGesture {
                selectedPlan = planIndex
            }
        
    }
}
