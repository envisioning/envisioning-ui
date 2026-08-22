import CoreGraphics

/// One corner scale for both apps. Three rungs, chosen by what the shape is,
/// not by how big it happens to be.
public enum EnvisioningRadius {
    /// Typed inputs and other sunken wells.
    public static let field: CGFloat = 12
    /// Buttons and anything else the pointer acts on.
    public static let control: CGFloat = 14
    /// Cards and grouped containers.
    public static let card: CGFloat = 18
}
